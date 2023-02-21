
# Mullets-Stack

This is a bash script to quickly setup a monorepo for quick ideation. Creates a monorepo containing both frontend and backend.

This will install the latest versions of:

- Client
    - Vite
    - Typescript
    - React (w/router-dom)
    - Chakra (optional)
- Server
    - Express
    - axios
    - dotenv
    - pg (postgresql)
    - knex
        - includes some scripts to get you rolling w/migrations

## Things to note

I'm using Knex for working with Postgres, you may not like that but it's here for now. I haven't verified TS Config is correct, just yet, but soon.

There's no .eslint / semantic versioning actions yet. Definitely coming soon.


## Installation

Clone the repo down or just the `mullets-stack.sh`

The only pre-requisite installation is `jq`. It will let us append to an existing `package.json` file.

```bash
    brew install jq
```

Once the script is downloaded, move it to a folder and run the script. It will create a new folder containing both Client and Server folders.

Give permission for the bash script to execute on your machine
```bash
  chmod +x mullets-stack.sh
```

Execute script
```bash
  ./mullets-stack.sh project_name
```

If you'd like to install Chakra UI as well, you can add it

```bash
  ./mullets-stack.sh project_name chakra
```
