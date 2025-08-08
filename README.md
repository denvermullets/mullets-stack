
# Mullets-Stack

This is a bash script to quickly setup a monorepo for quick ideation. Gives options for the following:

- React w/Tailwind, NodeJS, Express, Knex, and Postgres
- NodeJS API, with Express, Knex, and Postgres

### !! these are deprecated or not guaranteed to work !!
- React w/Chakra UI, NodeJS, Express, Knex, and Postgres
- React with Chakra UI
- Electron app with Chakra UI

This will install the latest (stable) versions of:

- Client
    - Vite
    - Typescript
    - React (w/router-dom)
    - JS/css framework choice (chakra / tailwind)
- Server
    - Express
    - axios
    - dotenv
    - pg (postgresql)
    - knex
        - includes some scripts to get you rolling w/migrations
- Electron
- husky
  - it also adds a pre-commit check for TS

## Things to note

I'm using Knex for working with Postgres, you may not like that but it's here for now.

There's no .eslint / semantic versioning actions yet. I'm also going to add my strict rulesets, just as a personal preference. Will be optional but definitely coming soon.


## Installation

Clone the repo down

#### Note
You may not need to install anything or change permissions, but if it doesn't run then scope these out

The only pre-requisite installation is `jq` and `newt`. It will let us append to an existing `package.json` file and gives us some options for terminal use.

```bash
    brew install jq
    brew install newt
```

Once the script is downloaded, move it to a folder and run the script. It will create a new folder containing both Client and Server folders.

Give permission for the bash script to execute on your machine. Execute from where the scripts are downloaded to.
```bash
  chmod -R +x *.sh
```

Execute script
```bash
  ./mullets-stack.sh
```
For extra convenience I have aliased the script, I would suggest the same to you.

## Roadmap

I'd like to have a version with Rails/React and then maybe an option with Nextjs/Rails
