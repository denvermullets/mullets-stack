
# Mullets-Stack

This is a bash script to quickly setup a monorepo for quick ideation. Gives options for the following:

- React w/Chakra UI, NodeJS, Express, Knex, and Postgres
- React with Chakra UI (not completed yet but you can just use Vite w/a template)
- NodeJS API, with Express, Knex, and Postgres
- Electron app with Chakra UI

This will install the latest versions of:

- Client
    - Vite
    - Typescript
    - React (w/router-dom)
    - Chakra (sorry, i love using it, easy to remove)
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

I'm using Knex for working with Postgres, you may not like that but it's here for now. I haven't verified TS Config is correct, just yet, but soon.

There's no .eslint / semantic versioning actions yet. Definitely coming soon.


## Installation

Clone the repo down

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
