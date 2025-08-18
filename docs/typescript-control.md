# Contrôle TypeScript

**Problème résolu** : Le hook TypeScript strict peut saturer le contexte avec trop d'erreurs.

## Solution : Variable d'Environnement

### 🎯 **Contrôle Rapide via Commands**

#### Désactiver (temporaire)
```bash
/disable-ts-check
```
- Modifie `CLAUDE_NO_TS_CHECK: "true"` dans settings.json
- Claude Code ne sera plus bloqué par les erreurs TS
- Les autres hooks restent actifs (sécurité, prettier, eslint)

#### Réactiver
```bash
/enable-ts-check
```
- Modifie `CLAUDE_NO_TS_CHECK: "false"` dans settings.json
- Remet la vérification TypeScript stricte
- Bloque Claude si erreurs TS détectées

### 🔧 **Configuration Manuel**

Dans `~/.claude/settings.json` :
```json
{
  "env": {
    "CLAUDE_NO_ANY": "true",
    "CLAUDE_NO_TS_CHECK": "false"    // true = désactivé, false = activé
  }
}
```

### 📊 **États du Pipeline**

#### Avec TS Check Activé (`"false"`)
- ✅ Validation sécurité (Bash)
- ✅ Prettier (formatage)
- ✅ ESLint (si présent)
- ✅ **TypeScript compilation**
- ✅ **Strict rules (any/unknown)**

#### Avec TS Check Désactivé (`"true"`)
- ✅ Validation sécurité (Bash)
- ✅ Prettier (formatage)
- ✅ ESLint (si présent)
- ❌ TypeScript compilation (sautée)
- ❌ Strict rules (any/unknown) (sautées)

### 🎮 **Workflow Recommandé**

1. **Développement rapide** :
   - `/disable-ts-check` pour prototyper sans blocage
   - Focus sur la logique métier

2. **Validation qualité** :
   - `/enable-ts-check` avant commit
   - Corriger les erreurs TypeScript
   - Ensure la qualité du code

3. **Debug context saturation** :
   - Si "Context low" apparaît souvent
   - `/disable-ts-check` temporairement
   - Nettoyer les erreurs TS manuellement
   - `/enable-ts-check` une fois propre

### 🔍 **Identification des Problèmes**

**Symptômes de saturation** :
- Message "Context low · Run /compact to compact & continue"
- Claude Code dit qu'il ne peut plus continuer
- Beaucoup d'erreurs TS dans le contexte

**Solution immédiate** :
1. `/disable-ts-check`
2. Continuer votre travail
3. Nettoyer les TS errors manuellement
4. `/enable-ts-check` quand prêt

### 📝 **Notes Techniques**

- Le hook vérifie `process.env.CLAUDE_NO_TS_CHECK === 'true'`
- Si true, il exit(0) immédiatement sans vérification
- Si false ou undefined, il continue la vérification normale
- Changement immédiat, pas besoin de redémarrer Claude Code

Cette solution vous donne le **contrôle total** sur quand utiliser la validation TypeScript stricte ! 🎯