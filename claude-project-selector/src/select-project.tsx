import {
  List,
  ActionPanel,
  Action,
  showToast,
  Toast,
  getPreferenceValues,
} from "@raycast/api";
import { useState, useEffect } from "react";
import { execSync } from "child_process";
import { existsSync, readdirSync, statSync, readFileSync } from "fs";
import { join } from "path";

interface Project {
  name: string;
  path: string;
  sessionCount: number;
  lastModified: Date;
  displayName: string;
}

interface Preferences {
  claudePath: string;
  obsidianVaultPath: string;
}

export default function SelectClaudeProject() {
  const [projects, setProjects] = useState<Project[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const preferences = getPreferenceValues<Preferences>();

  const claudePath = preferences.claudePath || `${process.env.HOME}/.claude`;
  const projectsPath = join(claudePath, "projects");

  useEffect(() => {
    const loadProjects = async () => {
      try {
        if (!existsSync(projectsPath)) {
          await showToast({
            style: Toast.Style.Failure,
            title: "Erreur",
            message: `Dossier Claude projects non trouvé: ${projectsPath}`,
          });
          setIsLoading(false);
          return;
        }

        const projectList: Project[] = [];

        // Scanner récursivement les dossiers de projets
        const scanDirectory = (dirPath: string, relativePath = ""): void => {
          try {
            const items = readdirSync(dirPath);

            // Compter les fichiers .jsonl dans ce dossier
            const jsonlFiles = items.filter((item) => item.endsWith(".jsonl"));

            if (jsonlFiles.length > 0) {
              // Ce dossier contient des sessions Claude
              const stats = statSync(dirPath);
              const projectName =
                relativePath || dirPath.split("/").pop() || dirPath;

              // Nettoyer et améliorer le nom d'affichage
              let displayName = projectName.replace(/\//g, " › ");

              // Nettoyer les noms de projets commençant par -Users-flo-
              if (displayName.startsWith("-Users-flo-")) {
                displayName = displayName
                  .replace("-Users-flo-", "~")
                  .replace(/-/g, "/");
              }

              // Simplifier les chemins longs
              displayName = displayName
                .replace("Code › nextjs › ", "📦 ")
                .replace("Code › github › claude › task › ", "⚡ ")
                .replace("Obsidian › ", "📝 ")
                .replace("Users › flo › ", "~/");

              projectList.push({
                name: projectName,
                path: relativePath || dirPath,
                sessionCount: jsonlFiles.length,
                lastModified: stats.mtime,
                displayName: displayName,
              });
            }

            // Scanner les sous-dossiers
            for (const item of items) {
              const fullPath = join(dirPath, item);
              if (statSync(fullPath).isDirectory()) {
                const newRelativePath = relativePath
                  ? `${relativePath}/${item}`
                  : item;
                scanDirectory(fullPath, newRelativePath);
              }
            }
          } catch (error) {
            console.error(`Erreur lors du scan de ${dirPath}:`, error);
          }
        };

        scanDirectory(projectsPath);

        // Trier par date de modification (plus récent en premier)
        projectList.sort(
          (a, b) => b.lastModified.getTime() - a.lastModified.getTime(),
        );

        setProjects(projectList);
      } catch (error) {
        await showToast({
          style: Toast.Style.Failure,
          title: "Erreur",
          message: `Impossible de charger les projets: ${error}`,
        });
      } finally {
        setIsLoading(false);
      }
    };

    loadProjects();
  }, [projectsPath]);

  const exportProject = async (project: Project) => {
    try {
      await showToast({
        style: Toast.Style.Animated,
        title: "Export en cours...",
        message: `Projet: ${project.displayName}`,
      });

      // Trouver le dernier fichier JSONL du projet
      const fullProjectPath = join(projectsPath, project.path);
      const jsonlFiles = readdirSync(fullProjectPath)
        .filter((file) => file.endsWith(".jsonl"))
        .map((file) => ({
          name: file,
          path: join(fullProjectPath, file),
          mtime: statSync(join(fullProjectPath, file)).mtime,
        }))
        .sort((a, b) => b.mtime.getTime() - a.mtime.getTime());

      if (jsonlFiles.length === 0) {
        throw new Error("Aucun fichier de session trouvé");
      }

      const latestSession = jsonlFiles[0];

      // Lire le fichier JSONL efficacement avec fs natif
      let sessionContent: string;
      try {
        sessionContent = readFileSync(latestSession.path, 'utf-8');
      } catch (error) {
        console.error(`Erreur lecture fichier: ${error}`);
        throw new Error(`Impossible de lire le fichier: ${error}`);
      }

      const sessionLines = sessionContent
        .trim()
        .split('\n')
        .filter(line => line.trim());

      if (sessionLines.length === 0) {
        throw new Error("Session vide");
      }

      // Pour optimiser sur les gros fichiers, on limite la recherche aux 100 dernières lignes
      const linesToCheck = Math.min(100, sessionLines.length);
      let lastAssistantMessage = null;
      
      // Parcourir depuis la fin pour trouver le dernier message assistant
      for (let i = sessionLines.length - 1; i >= Math.max(0, sessionLines.length - linesToCheck); i--) {
        try {
          const lineData = JSON.parse(sessionLines[i]);
          
          // Chercher un message assistant avec du contenu textuel
          if (lineData.message && 
              lineData.message.role === "assistant" && 
              lineData.message.content && 
              Array.isArray(lineData.message.content)) {
            
            // Vérifier qu'il y a au moins un élément de type "text"
            const hasText = lineData.message.content.some(
              (item: any) => item.type === "text" && item.text && item.text.trim() !== ""
            );
            
            if (hasText) {
              lastAssistantMessage = lineData.message;
              break;
            }
          }
        } catch (e) {
          // Ignorer les lignes qui ne sont pas du JSON valide (silencieusement)
          continue;
        }
      }

      if (!lastAssistantMessage) {
        // Si on n'a pas trouvé dans les 100 dernières, essayer de chercher plus loin
        for (let i = Math.max(0, sessionLines.length - linesToCheck - 1); i >= 0; i--) {
          try {
            const lineData = JSON.parse(sessionLines[i]);
            
            if (lineData.message && 
                lineData.message.role === "assistant" && 
                lineData.message.content && 
                Array.isArray(lineData.message.content)) {
              
              const hasText = lineData.message.content.some(
                (item: any) => item.type === "text" && item.text && item.text.trim() !== ""
              );
              
              if (hasText) {
                lastAssistantMessage = lineData.message;
                break;
              }
            }
          } catch (e) {
            continue;
          }
        }
      }

      if (!lastAssistantMessage) {
        throw new Error("Aucun message assistant avec du contenu trouvé dans la session");
      }

      const lastMessage = lastAssistantMessage;

      // Debug: log de la structure
      console.log("Message trouvé:", {
        role: lastMessage.role,
        model: lastMessage.model,
        contentLength: lastMessage.content?.length
      });

      // Créer le contenu pour Obsidian
      const now = new Date();
      const timestamp = now
        .toISOString()
        .slice(0, 19)
        .replace(/[-:]/g, "")
        .replace("T", "_");
      
      // Créer un nom de fichier plus court et lisible
      const projectNameClean = project.name
        .replace(/-Users-[^-]+-/g, "") // Supprimer -Users-XXX-
        .replace(/^-+/, "") // Supprimer les tirets au début
        .replace(/-+$/, "") // Supprimer les tirets à la fin
        .replace(/--+/g, "-") // Remplacer les doubles tirets
        .replace(/\//g, "-")
        .replace(/\s+/g, "-")
        .toLowerCase()
        .slice(0, 30); // Limiter la longueur
      
      const filename = `claude_${projectNameClean}_${timestamp}`;

      const vaultPath =
        preferences.obsidianVaultPath ||
        `${process.env.HOME}/Obsidian Vault/00_Capture`;

      // S'assurer que le dossier existe
      execSync(`mkdir -p "${vaultPath}"`);

      // Extraire le contenu du message selon son format
      let messageContent = "Contenu non disponible";

      if (lastMessage.content) {
        if (typeof lastMessage.content === "string") {
          messageContent = lastMessage.content;
        } else if (Array.isArray(lastMessage.content)) {
          // Gérer les messages avec content array (tool_use, text, etc.)
          const contentParts = lastMessage.content
            .map((item: any) => {
              if (item.type === "text" && item.text) {
                return item.text;
              } else if (item.type === "tool_use") {
                // Formater les tool_use de manière plus lisible
                const toolName = item.name || "Tool";
                const toolInput = item.input ? JSON.stringify(item.input, null, 2) : "{}";
                return `### 🔧 Tool: ${toolName}\n\`\`\`json\n${toolInput}\n\`\`\``;
              } else if (item.type === "tool_result") {
                // Gérer les résultats d'outils
                return `### ✅ Tool Result\n\`\`\`\n${item.content || JSON.stringify(item, null, 2)}\n\`\`\``;
              } else {
                // Fallback pour autres types
                return `\`\`\`json\n${JSON.stringify(item, null, 2)}\n\`\`\``;
              }
            })
            .filter((content: string) => content && content.trim() !== "");
          
          messageContent = contentParts.length > 0 
            ? contentParts.join("\n\n") 
            : "Aucun contenu textuel trouvé";
        } else {
          messageContent = JSON.stringify(lastMessage.content, null, 2);
        }
      }

      // Générer les tags basés sur le projet
      const projectTags = [];
      if (project.displayName.includes("Code")) projectTags.push("code");
      if (project.displayName.includes("nextjs")) projectTags.push("nextjs");
      if (project.displayName.includes("Obsidian")) projectTags.push("obsidian");
      if (project.displayName.includes("github")) projectTags.push("github");
      if (project.displayName.includes("claude")) projectTags.push("ai");


      // Créer le contenu avec frontmatter YAML minimal
      const noteContent = `---
title: "${project.displayName}"
date: ${now.toISOString()}
tags:
  - claude-code
  ${projectTags.map(tag => `- ${tag}`).join("\n  ")}
project: "${project.displayName}"
model: "${lastMessage.model || 'unknown'}"
---

${messageContent}
`;

      // Écrire le fichier
      const notePath = join(vaultPath, `${filename}.md`);
      execSync(`cat > "${notePath}" << 'EOF'\n${noteContent}\nEOF`);

      // Ouvrir dans Obsidian
      const obsidianUrl = `obsidian://open?vault=Obsidian%20Vault&file=00_Capture/${filename}`;
      execSync(`open "${obsidianUrl}"`);

      await showToast({
        style: Toast.Style.Success,
        title: "✅ Export réussi",
        message: `Note créée: ${filename}.md`,
      });
    } catch (error) {
      await showToast({
        style: Toast.Style.Failure,
        title: "❌ Erreur d'export",
        message: `${error}`,
      });
    }
  };

  const formatDate = (date: Date): string => {
    return date.toLocaleDateString("fr-FR", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  return (
    <List
      isLoading={isLoading}
      navigationTitle="Sélectionner Projet Claude Code"
      searchBarPlaceholder="Rechercher un projet..."
    >
      {projects.length === 0 && !isLoading ? (
        <List.EmptyView
          title="Aucun projet trouvé"
          description={`Vérifiez que des projets existent dans ${projectsPath}`}
        />
      ) : (
        projects.map((project) => (
          <List.Item
            key={project.path}
            title={project.displayName}
            subtitle={`${project.sessionCount} session${project.sessionCount > 1 ? "s" : ""}`}
            accessories={[{ text: formatDate(project.lastModified) }]}
            actions={
              <ActionPanel>
                <Action
                  title="Exporter Vers Obsidian"
                  onAction={() => exportProject(project)}
                />
                <Action.ShowInFinder
                  title="Ouvrir Dans Finder"
                  path={join(projectsPath, project.path)}
                />
              </ActionPanel>
            }
          />
        ))
      )}
    </List>
  );
}
