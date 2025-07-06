#!/usr/bin/env node
import yargs from 'yargs/yargs';
import { hideBin } from "yargs/helpers"
import chalk from "chalk"
import ora from "ora"
import fs from "fs/promises"

// --- Configuration ---
const API_BASE_URL = "https://context7.com"
const PROJECTS_API_URL = `${API_BASE_URL}/api/projects`
const USER_AGENT = "c7-cli/1.0.3" // Increment version example

// --- Helper Functions ---
function formatJsonOutput(data) {
  /* ... as before ... */ return JSON.stringify(data, null, 2)
}
function printHeaderFooter(isHeader = true) {
  /* ... as before ... */
  let termWidth = process.stdout.columns || 80
  termWidth = Math.max(4, termWidth)
  const text = isHeader ? " Context7 CLI " : " Data provided by Context7 API "
  const textLength = text.length
  let paddingLength = Math.floor((termWidth - textLength) / 2) - 1
  paddingLength = Math.max(0, paddingLength)
  const padding = " ".repeat(paddingLength)
  const totalInnerLength = padding.length * 2 + textLength
  let rightPaddingLength = termWidth - totalInnerLength - 2
  rightPaddingLength = Math.max(0, rightPaddingLength)
  const rightPadding = " ".repeat(rightPaddingLength)
  const line = "─".repeat(termWidth > 2 ? termWidth - 2 : 0)
  const border = chalk.blueBright.bold
  const footerBorderStyle = chalk.dim.blue
  if (isHeader) {
    console.log(border(`┌${line}┐`))
    const content = `${padding}${text}${rightPadding}`
    const safeContent = content.slice(0, termWidth - 2)
    const finalPadding = " ".repeat(
      Math.max(0, termWidth - 2 - safeContent.length)
    )
    console.log(border(`│${safeContent}${finalPadding}│`))
    console.log(border(`└${line}┘`))
  } else {
    console.log(footerBorderStyle(`\n┌${line}┐`))
    const content = `${padding}${text}${rightPadding}`
    const safeContent = content.slice(0, termWidth - 2)
    const finalPadding = " ".repeat(
      Math.max(0, termWidth - 2 - safeContent.length)
    )
    console.log(footerBorderStyle(`│${safeContent}${finalPadding}│`))
    console.log(footerBorderStyle(`└${line}┘\n`))
  }
}
// Fetches the full list of projects (cached within a single run)
let projectListCache = null
async function fetchProjects() {
  if (projectListCache) {
    return projectListCache
  }
  // console.error(chalk.dim("Fetching project list...")); // Optional debug log
  try {
    const response = await fetch(PROJECTS_API_URL, {
      headers: { "User-Agent": USER_AGENT }
    })
    if (!response.ok) {
      throw new Error(
        `Failed to fetch projects: ${response.status} ${response.statusText}`
      )
    }
    const data = await response.json()
    if (!Array.isArray(data)) {
      throw new Error("Invalid project list format received from API.")
    }
    projectListCache = data
    return projectListCache
  } catch (error) {
    projectListCache = null // Clear cache on error
    console.error("Error fetching projects:", error)
    throw error
  }
}

// --- Project Path Resolution Function (NEW) ---
async function resolveProjectPath(identifier) {
  if (
    !identifier ||
    typeof identifier !== "string" ||
    identifier.trim() === ""
  ) {
    throw new Error("Project identifier cannot be empty.")
  }

  const projects = await fetchProjects()
  const trimmedIdentifier = identifier.trim()

  // 1. Check if it's already the full path format '/org/repo'
  if (trimmedIdentifier.startsWith("/") && trimmedIdentifier.includes("/")) {
    const exactMatch = projects.find(
      p => p?.settings?.project === trimmedIdentifier
    )
    if (exactMatch) {
      return trimmedIdentifier // Found exact match
    }
    // If not found, fall through to other checks in case of typo or similar
  }

  // 2. Check if it's 'org/repo' format (missing leading slash)
  if (!trimmedIdentifier.startsWith("/") && trimmedIdentifier.includes("/")) {
    const potentialPath = `/${trimmedIdentifier}`
    const exactMatch = projects.find(
      p => p?.settings?.project === potentialPath
    )
    if (exactMatch) {
      return potentialPath // Found exact match by adding slash
    }
    // If not found, continue to repo-only check
  }

  // 3. Check if it's just 'repo' format (and potentially ambiguous)
  const repoNameOnly = trimmedIdentifier.includes("/")
    ? trimmedIdentifier.substring(trimmedIdentifier.lastIndexOf("/") + 1)
    : trimmedIdentifier

  const possibleMatches = projects.filter(
    // Ensure it's the new format
    p =>
      p?.settings?.project?.endsWith(`/${repoNameOnly}`) &&
      p?.settings?.project?.includes("/")
  )

  if (possibleMatches.length === 1) {
    return possibleMatches[0].settings.project // Found unique match by repo name
  }

  if (possibleMatches.length > 1) {
    // Ambiguous! List options for the user.
    const options = possibleMatches
      .map(p => `  - ${p.settings.project} (${p.settings.title})`)
      .join("\n")
    throw new Error(
      `Ambiguous project identifier "${identifier}". Found multiple matches:\n${options}\nPlease use a more specific path (e.g., /org/repo or org/repo).`
    )
  }

  // 4. Not Found after all checks
  throw new Error(
    `Could not resolve project identifier "${identifier}" to a valid project path. Use 'c7 search <term>' to find projects.`
  )
}

// --- Search Function (MODIFIED) ---
async function handleSearch(searchTerm) {
  printHeaderFooter(true)
  const spinner = ora({
    text: chalk.cyan(`Searching for projects matching "${searchTerm}"...`),
    spinner: "dots"
  }).start()
  try {
    const projects = await fetchProjects() // Use helper to potentially get cached list
    spinner.text = chalk.cyan("Filtering results...")

    const lowerSearchTerm = searchTerm.toLowerCase()
    const matches = projects
      .filter(
        // MUST include '/' (new format)
        p =>
          (p?.settings?.title?.toLowerCase().includes(lowerSearchTerm) ||
            p?.settings?.project?.toLowerCase().includes(lowerSearchTerm)) && // Match title OR path
          p?.settings?.project?.includes("/")
      )
      .map(p => ({
        title: p.settings.title,
        name: p.settings.project // The usable name is the full path
      }))
    // Sort matches alphabetically by title for better readability
    matches.sort((a, b) => a.title.localeCompare(b.title))

    if (matches.length > 0) {
      spinner.succeed(
        chalk.green(`Found ${matches.length} matching project(s):`)
      )
      console.log(
        chalk.yellow(
          '\n--- Search Results (Use "Project Path" for queries) ---'
        )
      )
      matches.forEach(m =>
        console.log(
          chalk.magenta(`  - ${m.title}`) +
            chalk.dim(` (Project Path: ${chalk.cyan(m.name)})`)
        )
      )
      console.log(
        chalk.yellow(
          "--------------------------------------------------------\n"
        )
      )
      console.log(
        chalk.cyan(`Example query: c7 "${matches[0].name}" <your query>`)
      ) // Quote path in example
    } else {
      spinner.info(
        chalk.yellow(
          `No projects found matching "${searchTerm}" with format /org/repo.`
        )
      )
    }
    printHeaderFooter(false)
  } catch (error) {
    spinner.fail(chalk.red("Error during search!"))
    console.error(chalk.red(error.message))
    printHeaderFooter(false)
    process.exit(1)
  }
}

// --- Query Function (MODIFIED) ---
async function handleQuery(
  projectIdentifier,
  query,
  format,
  saveToFile,
  maxTokens
) {
  // Now takes user input identifier
  let resolvedPath = ""
  const spinner = ora(
    chalk.cyan(`Resolving project "${projectIdentifier}"...`)
  ).start()

  try {
    resolvedPath = await resolveProjectPath(projectIdentifier) // Resolve first
    spinner.text = chalk.cyan(
      `Fetching data for project "${resolvedPath}" on topic "${query}"...`
    ) // Use resolved path in messages

    const encodedQuery = encodeURIComponent(query)
    let apiUrl = `${API_BASE_URL}${resolvedPath}/llms.${format}?topic=${encodedQuery}`

    if (maxTokens !== undefined && maxTokens !== null) {
      if (typeof maxTokens === "number" && maxTokens > 0) {
        apiUrl += `&tokens=${maxTokens}`
      } else if (
        process.argv.includes("--tokens") ||
        process.argv.includes("-k")
      ) {
        spinner.warn(
          chalk.yellow(
            `Invalid --tokens value ignored. Must be a positive number.`
          )
        )
      }
    }

    spinner.text = chalk.cyan(`Querying: ${apiUrl}`)
    const response = await fetch(apiUrl, {
      headers: { "User-Agent": USER_AGENT }
    })

    if (!response.ok) {
      spinner.fail(
        chalk.red(
          `API request failed: ${response.status} ${response.statusText}`
        )
      )
      try {
        const errorBody = await response.text()
        console.error(chalk.red("Error details:", errorBody))
      } catch (e) {
        /* ignore */
      }
      printHeaderFooter(false)
      process.exit(1)
    }

    let data
    if (format === "json") {
      data = await response.json()
    } else {
      data = await response.text()
    }

    if (saveToFile) {
      const sanitizedPath = (resolvedPath.startsWith("/")
        ? resolvedPath.substring(1)
        : resolvedPath
      ).replace(/\//g, "_")
      const filename = `llms_${sanitizedPath}.${format}`
      const contentToWrite = format === "json" ? formatJsonOutput(data) : data
      await fs.writeFile(filename, contentToWrite)
      spinner.succeed(
        chalk.green(
          `Successfully saved data for "${resolvedPath}" to ${chalk.cyan(
            filename
          )}!`
        )
      )
    } else {
      spinner.succeed(
        chalk.green(`Successfully fetched data for "${resolvedPath}"!`)
      )
      console.log(
        chalk.bold(`\n--- Query Result (${format.toUpperCase()}) ---`)
      )
      if (format === "json") {
        console.log(chalk.magenta(formatJsonOutput(data)))
      } else {
        console.log(chalk.white(data))
      }
    }
    printHeaderFooter(false)
  } catch (error) {
    // Handle errors from resolveProjectPath OR the fetch/save process
    spinner.fail(chalk.red(`Error: ${error.message}`))
    // console.error(chalk.red(error.stack)); // Optional: more detailed stack trace
    printHeaderFooter(false)
    process.exit(1)
  }
}

// --- Info Function (MODIFIED) ---
async function handleInfo(projectIdentifier) {
  // Now takes user input identifier
  let resolvedPath = ""
  const spinner = ora(
    chalk.cyan(`Resolving project "${projectIdentifier}"...`)
  ).start()

  try {
    resolvedPath = await resolveProjectPath(projectIdentifier) // Resolve first
    spinner.text = chalk.cyan(`Fetching info for project "${resolvedPath}"...`)

    // We need the project list again to find the details for the resolved path
    // Could optimize by having resolveProjectPath return the project object too
    const projects = await fetchProjects()
    const projectInfo = projects.find(
      p => p?.settings?.project === resolvedPath
    )

    if (projectInfo) {
      spinner.succeed(chalk.green(`Found info for "${resolvedPath}":`))
      const s = projectInfo.settings || {}
      const v = projectInfo.version || {}
      console.log(chalk.yellow("\n--- Project Information ---"))
      console.log(
        `${chalk.blueBright.bold("Title:")}         ${chalk.white(
          s.title || "N/A"
        )}`
      )
      console.log(
        `${chalk.blueBright.bold("Project Path:")}  ${chalk.cyan(s.project)}`
      )
      console.log(
        `${chalk.blueBright.bold("Docs Source:")}   ${chalk.green(
          s.docsRepoUrl || "N/A"
        )}`
      )
      console.log(
        `${chalk.blueBright.bold("Branch:")}        ${chalk.white(
          s.branch || "N/A"
        )}`
      )
      console.log(chalk.yellow("--- Processing Version ---"))
      console.log(
        `${chalk.blueBright.bold("State:")}         ${chalk.white(
          v.state || "N/A"
        )}`
      )
      console.log(
        `${chalk.blueBright.bold("Last Update:")}   ${chalk.white(
          v.lastUpdate || "N/A"
        )}`
      )
      console.log(
        `${chalk.blueBright.bold("Total Pages:")}   ${chalk.white(
          v.totalPages ?? "N/A"
        )}`
      )
      console.log(
        `${chalk.blueBright.bold("Total Snippets:")} ${chalk.white(
          v.totalSnippets ?? "N/A"
        )}`
      )
      console.log(
        `${chalk.blueBright.bold("Errors Count:")}  ${chalk.white(
          v.errorCount ?? "N/A"
        )}`
      )
      if (Array.isArray(s.excludeFolders) && s.excludeFolders.length > 0) {
        console.log(chalk.yellow("--- Excluded Folders ---"))
        s.excludeFolders.forEach(folder =>
          console.log(chalk.dim(`  - ${folder}`))
        )
      }
      console.log(chalk.yellow("-------------------------\n"))
    } else {
      // This case *shouldn't* happen if resolveProjectPath worked, but good to keep
      spinner.fail(
        chalk.red(
          `Internal error: Could not find details for resolved path "${resolvedPath}".`
        )
      )
    }
    printHeaderFooter(false)
  } catch (error) {
    // Handle errors from resolveProjectPath OR fetchProjects
    spinner.fail(chalk.red(`Error: ${error.message}`))
    // console.error(chalk.red(error.stack)); // Optional: more detailed stack trace
    printHeaderFooter(false)
    process.exit(1)
  }
}

// --- Main Execution ---
yargs(hideBin(process.argv))
  // --- Default Command (Query) (MODIFIED) ---
  .command(
    '$0 <projectIdentifier> [query...]',
    'Query Context7 API using a project path or name', // Slightly broader description
    (yargs) => {
         yargs
            .positional('projectIdentifier', {
                // Updated description:
                describe: chalk.green('Project path (/org/repo), partial path (org/repo), or unique name (repo). Use "c7 search <term>" to find valid identifiers.'),
                type: 'string'
            })
            .positional('query', { describe: chalk.green('Topic/question to query'), type: 'array' })
            .option('type', { alias: 't', describe: chalk.yellow('Output format'), choices: ['txt', 'json'], default: 'txt', type: 'string' })
            .option('save', { alias: 's', describe: chalk.yellow('Save output to file'), type: 'boolean', default: false })
            .option('tokens', { alias: 'k', describe: chalk.yellow('Max tokens'), type: 'number', default: 5000 })
            .check((argv) => { if (!argv.query || argv.query.length === 0) { throw new Error(chalk.red('Missing query.')); } return true; });
    },
    async (argv) => { await handleQuery(argv.projectIdentifier, argv.query.join(' '), argv.type, argv.save, argv.tokens); }
)
  // --- Search Command ---
  .command(
    'search <term>', 'Search for projects and their paths', // Slightly updated description
    (yargs) => { yargs.positional('term', { describe: chalk.green('Keyword for title/path'), type: 'string' }); },
    async (argv) => { await handleSearch(argv.term); }
)
  // --- Info Command (MODIFIED) ---
  .command(
    'info <projectIdentifier>', // Argument name reflects flexibility
    'Display metadata about a specific project', // Kept description simple
    (yargs) => { yargs.positional('projectIdentifier', { // Updated argument name
        // Updated description:
        describe: chalk.green('Project path (/org/repo), partial path (org/repo), or unique name (repo). Use "c7 search <term>" to find valid identifiers.'),
        type: 'string' }); },
    async (argv) => { await handleInfo(argv.projectIdentifier); } // Pass identifier
)
  // --- Global Options & Settings ---
  .demandCommand(1, chalk.yellow('Specify command (search, info) or query params.'))
    .alias('h', 'help').alias('v', 'version').strict().wrap(process.stdout.columns)
    .fail((msg, err, yargsInstance) => { /* ... fail handler ... */
        console.error(chalk.red.bold('\n❌ Error!')); if (msg) { console.error(chalk.red(msg)); } else if (err) { console.error(chalk.red(err.message)); }
        const scriptName = yargsInstance?.$0 || 'c7'; console.error(chalk.yellow(`\nRun "${scriptName} --help" for usage information.`)); printHeaderFooter(false); process.exit(1);
    })
    .parse();
