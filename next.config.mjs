import { existsSync, readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

const propertiesPath = fileURLToPath(new URL("./app.properties", import.meta.url));

if (existsSync(propertiesPath)) {
  const lines = readFileSync(propertiesPath, "utf8").split(/\r?\n/);

  for (const [index, rawLine] of lines.entries()) {
    const line = rawLine.trim();
    if (!line || line.startsWith("#") || line.startsWith("!")) continue;

    const separator = line.indexOf("=");
    const key = line.slice(0, separator).trim();
    if (separator < 1 || !/^[A-Z][A-Z0-9_]*$/.test(key)) {
      throw new Error(`Invalid app.properties entry at line ${index + 1}; use KEY=value.`);
    }

    let value = line.slice(separator + 1).trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    if (value && process.env[key] === undefined) process.env[key] = value;
  }
}

const nextConfig = {};
export default nextConfig;
