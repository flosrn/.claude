// Test file for TypeScript quality hook - CORRECTED VERSION

const goodCode: string = "this is properly typed";
const alsoGood: string = "this too";

// Fixed without ignore
const notIgnored = "this is clean";

export function testFunction(param: string): string {
  return param;
}