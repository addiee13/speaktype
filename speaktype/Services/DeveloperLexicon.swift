import Foundation

struct DeveloperLexiconEntry: Hashable {
    let canonical: String
    let spokenVariants: [String]
    let profiles: Set<TranscriptionProfile>
    let commandHeadEligible: Bool
}

final class DeveloperLexicon {
    static let shared = DeveloperLexicon()

    let entries: [DeveloperLexiconEntry]
    let commandHeadTerms: Set<String>

    private init() {
        self.entries = Self.buildEntries()
        self.commandHeadTerms = Set(
            entries
                .filter(\.commandHeadEligible)
                .map { Self.commandHeadForm(for: $0.canonical) }
        )
    }

    private static func buildEntries() -> [DeveloperLexiconEntry] {
        var entries: [DeveloperLexiconEntry] = []

        entries += explicitBrandEntries
        entries += explicitFlagEntries
        entries += makeEntries(
            from: shellCommandsBlock,
            profiles: [.terminal, .code],
            commandHeadEligible: true
        )
        entries += makeEntries(
            from: cliToolsBlock,
            profiles: [.terminal, .code, .brainstorm, .prose],
            commandHeadEligible: true
        )
        entries += makeEntries(from: languagesBlock)
        entries += makeEntries(from: frameworksBlock)
        entries += makeEntries(from: frontendPackagesBlock)
        entries += makeEntries(from: backendPackagesBlock)
        entries += makeEntries(from: infraAndCloudBlock)
        entries += makeEntries(from: dataAndProtocolsBlock)

        return entries.sorted {
            longestVariantLength(for: $0) > longestVariantLength(for: $1)
        }
    }

    private static func longestVariantLength(for entry: DeveloperLexiconEntry) -> Int {
        entry.spokenVariants.map(\.count).max() ?? entry.canonical.count
    }

    private static func makeEntries(
        from block: String,
        profiles: Set<TranscriptionProfile> = TranscriptionProfile.allProfiles,
        commandHeadEligible: Bool = false
    ) -> [DeveloperLexiconEntry] {
        normalizedLines(from: block).map { canonical in
            DeveloperLexiconEntry(
                canonical: canonical,
                spokenVariants: spokenVariants(for: canonical),
                profiles: profiles,
                commandHeadEligible: commandHeadEligible
            )
        }
    }

    private static func normalizedLines(from block: String) -> [String] {
        block.split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private static func spokenVariants(for canonical: String) -> [String] {
        let normalized = normalizeVariant(canonical)
        let compact = normalized.replacingOccurrences(of: " ", with: "")
        var variants = [normalized, compact]

        if canonical.contains("GPT") {
            variants.append(normalized.replacingOccurrences(of: "gpt", with: "g p t"))
        }

        if canonical.contains("CLI") {
            variants.append(normalized.replacingOccurrences(of: "cli", with: "c l i"))
        }

        if canonical.contains("API") {
            variants.append(normalized.replacingOccurrences(of: "api", with: "a p i"))
        }

        return Array(Set(variants)).sorted { $0.count > $1.count }
    }

    static func normalizeVariant(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: " and ")
            .replacingOccurrences(of: "+", with: " plus ")
            .replacingOccurrences(of: "#", with: " sharp ")
            .replacingOccurrences(of: "@", with: " at ")
            .replacingOccurrences(of: ".", with: " ")
            .replacingOccurrences(of: "/", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(
                of: #"\s+"#,
                with: " ",
                options: .regularExpression
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    static func commandHeadForm(for canonical: String) -> String {
        canonical
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: #"[^\p{L}\p{N}./_+-]+"#, with: "", options: .regularExpression)
            .lowercased()
    }

    private static let explicitBrandEntries: [DeveloperLexiconEntry] = [
        entry("OpenAI", ["open ai", "openai"]),
        entry("ChatGPT", ["chat gpt", "chatgpt"]),
        entry("GPT-4", ["gpt 4", "g p t 4", "gpt four"]),
        entry("GPT-4o", ["gpt 4 o", "g p t 4 o", "gpt four o"]),
        entry("GPT-4.1", ["gpt 4 1", "g p t 4 1", "gpt four one"]),
        entry("Claude", ["claude"]),
        entry("Claude Code", ["claude code"]),
        entry("Gemini", ["gemini"]),
        entry("GitHub", ["github", "git hub"]),
        entry("GitLab", ["gitlab", "git lab"]),
        entry("Bitbucket", ["bitbucket", "bit bucket"]),
        entry("Stack Overflow", ["stack overflow"]),
        entry("Hugging Face", ["hugging face"]),
        entry("Perplexity", ["perplexity"]),
        entry("Vercel", ["vercel"]),
        entry("Netlify", ["netlify"]),
        entry("Cloudflare", ["cloudflare", "cloud flare"]),
        entry("DigitalOcean", ["digital ocean"]),
        entry("Render", ["render"]),
        entry("Fly.io", ["fly io", "fly dot io"]),
        entry("Railway", ["railway"]),
        entry("Supabase", ["supabase"]),
        entry("Firebase", ["firebase"]),
        entry("PlanetScale", ["planet scale"]),
        entry("MongoDB", ["mongo db", "mongodb"]),
        entry("PostgreSQL", ["postgres q l", "postgresql", "postgre sql"]),
        entry("MySQL", ["my sql", "mysql"]),
        entry("SQLite", ["sqlite", "s q l lite"]),
        entry("Redis", ["redis"]),
        entry("MariaDB", ["maria db", "mariadb"]),
        entry("Elasticsearch", ["elastic search", "elasticsearch"]),
        entry("OpenSearch", ["open search", "opensearch"]),
        entry("Node.js", ["node js", "node j s", "nodejs"]),
        entry("Next.js", ["next js", "next j s", "nextjs"]),
        entry("Nuxt.js", ["nuxt js", "nuxt j s", "nuxtjs"]),
        entry("NestJS", ["nest js", "nest j s", "nestjs"]),
        entry("Express.js", ["express js", "express j s", "expressjs"]),
        entry("SvelteKit", ["svelte kit", "sveltekit"]),
        entry("SolidJS", ["solid js", "solid j s", "solidjs"]),
        entry("Qwik", ["quick", "qwik"]),
        entry("Vue.js", ["vue js", "vue j s", "vuejs"]),
        entry("React", ["react"]),
        entry("Angular", ["angular"]),
        entry("TypeScript", ["typescript", "type script"]),
        entry("JavaScript", ["javascript", "java script"]),
        entry("C#", ["c sharp", "csharp"]),
        entry("F#", ["f sharp", "fsharp"]),
        entry("C++", ["c plus plus"]),
        entry("ASP.NET", ["asp dot net", "asp net"]),
        entry(".NET", ["dot net"]),
        entry("GraphQL", ["graph q l", "graphql"]),
        entry("REST API", ["rest api", "rest a p i"]),
        entry("gRPC", ["g r p c", "grpc"]),
        entry("WebSocket", ["web socket", "websocket"]),
        entry("OAuth", ["o auth", "oauth"]),
        entry("OpenID", ["open id", "openid"]),
        entry("JWT", ["j w t", "jwt"]),
        entry("CI/CD", ["c i c d", "ci cd"]),
        entry("SDK", ["s d k", "sdk"]),
        entry("CLI", ["c l i", "cli"]),
        entry("API", ["a p i", "api"]),
        entry("IDE", ["i d e", "ide"]),
        entry("README", ["read me", "readme"]),
        entry("Markdown", ["markdown"]),
        entry("JSON", ["j son", "j s o n", "json"]),
        entry("YAML", ["yaml", "ya mel"]),
        entry("TOML", ["t o m l", "toml"]),
        entry("CSV", ["c s v", "csv"]),
        entry("XML", ["x m l", "xml"]),
        entry("Docker", ["docker"]),
        entry("Kubernetes", ["kubernetes", "k eights", "k8s"]),
        entry("Terraform", ["terraform"]),
        entry("Ansible", ["ansible"]),
        entry("Pulumi", ["pulumi"]),
        entry("LangChain", ["lang chain", "langchain"]),
        entry("LlamaIndex", ["llama index"]),
        entry("Ollama", ["ollama"]),
        entry("Whisper", ["whisper"]),
        entry("WhisperKit", ["whisper kit", "whisperkit"]),
        entry("Core ML", ["core m l", "core ml"]),
        entry("Xcode", ["x code", "xcode"]),
        entry("VS Code", ["v s code", "vs code"]),
        entry("Cursor", ["cursor"]),
        entry("IntelliJ", ["intelij", "intellij"]),
        entry("PyCharm", ["py charm", "pycharm"]),
        entry("Android Studio", ["android studio"]),
        entry("JetBrains", ["jet brains", "jetbrains"]),
        entry("macOS", ["mac o s", "macos"]),
        entry("iOS", ["i o s", "ios"]),
        entry("watchOS", ["watch o s", "watchos"]),
        entry("visionOS", ["vision o s", "visionos"]),
        entry("Linux", ["linux"]),
        entry("Ubuntu", ["ubuntu"]),
        entry("Debian", ["debian"]),
        entry("CentOS", ["cent o s", "centos"]),
        entry("Fedora", ["fedora"]),
        entry("Homebrew", ["home brew", "homebrew"]),
        entry("npm", ["n p m", "npm"]),
        entry("pnpm", ["p n p m", "pnpm"]),
        entry("npx", ["n p x", "npx"]),
        entry("Yarn", ["yarn"]),
        entry("Bun", ["bun"]),
        entry("pip", ["pip"]),
        entry("uv", ["u v", "uv"]),
        entry("Conda", ["conda"]),
        entry("Poetry", ["poetry"]),
        entry("Cargo", ["cargo"]),
        entry("Rust", ["rust"]),
        entry("Go", ["go", "golang"]),
        entry("Golang", ["go lang", "golang"]),
        entry("Java", ["java"]),
        entry("Kotlin", ["kotlin"]),
        entry("Swift", ["swift"]),
        entry("Python", ["python"]),
        entry("Ruby", ["ruby"]),
        entry("PHP", ["p h p", "php"]),
        entry("Laravel", ["laravel"]),
        entry("Symfony", ["symfony"]),
        entry("Django", ["django"]),
        entry("FastAPI", ["fast api", "fastapi"]),
        entry("Flask", ["flask"]),
        entry("Pydantic", ["pydantic"]),
        entry("SQLAlchemy", ["sql alchemy", "s q l alchemy"]),
        entry("Celery", ["celery"]),
        entry("PyTorch", ["py torch", "pytorch"]),
        entry("TensorFlow", ["tensor flow", "tensorflow"]),
        entry("Scikit-learn", ["scikit learn", "sci kit learn"]),
        entry("NumPy", ["numpy", "num pi"]),
        entry("Pandas", ["pandas"]),
        entry("Polars", ["polars"]),
        entry("Apache Kafka", ["apache kafka"]),
        entry("RabbitMQ", ["rabbit m q", "rabbitmq"]),
        entry("NATS", ["nats", "n a t s"]),
        entry("OpenTelemetry", ["open telemetry", "opentelemetry"]),
        entry("Datadog", ["data dog", "datadog"]),
        entry("Sentry", ["sentry"]),
        entry("New Relic", ["new relic"]),
        entry("Auth0", ["auth zero", "auth0"]),
        entry("Okta", ["okta"]),
        entry("Clerk", ["clerk"]),
        entry("Stripe", ["stripe"]),
        entry("Twilio", ["twilio"]),
        entry("SendGrid", ["send grid", "sendgrid"]),
        entry("Mailgun", ["mail gun", "mailgun"]),
        entry("Resend", ["resend"]),
        entry("Slack", ["slack"]),
        entry("Discord", ["discord"]),
        entry("Notion", ["notion"]),
        entry("Linear", ["linear"]),
        entry("Atlassian", ["atlassian"]),
        entry("Jira", ["jira"]),
        entry("Confluence", ["confluence"]),
        entry("Postman", ["postman"]),
        entry("Insomnia", ["insomnia"]),
        entry("Deno", ["deno"]),
        entry("Electron", ["electron"]),
        entry("Tauri", ["tauri"]),
        entry("Playwright", ["playwright"]),
        entry("Cypress", ["cypress"]),
        entry("Selenium", ["selenium"]),
        entry("Vitest", ["vitest"]),
        entry("Jest", ["jest"]),
        entry("Mocha", ["mocha"]),
        entry("Chai", ["chai"]),
        entry("Storybook", ["story book", "storybook"]),
        entry("Tailwind CSS", ["tailwind css", "tailwind c s s", "tailwindcss"]),
        entry("Bootstrap", ["bootstrap"]),
        entry("Material UI", ["material ui", "material u i"]),
        entry("shadcn/ui", ["shadcn ui", "shadcn"]),
        entry("Prisma", ["prisma"]),
        entry("Drizzle", ["drizzle"]),
        entry("NextAuth", ["next auth", "nextauth"]),
        entry("TanStack Query", ["tan stack query", "tanstack query"]),
        entry("React Router", ["react router"]),
        entry("React Native", ["react native"]),
        entry("Expo", ["expo"]),
        entry("Electron Forge", ["electron forge"]),
        entry("TurboRepo", ["turbo repo", "turborepo"]),
        entry("Nx", ["n x", "nx"]),
        entry("pnpm", ["p n p m", "pnpm"]),
        entry("Codex", ["codex"], profiles: [.terminal, .code, .brainstorm, .prose], commandHeadEligible: true),
    ]

    private static let explicitFlagEntries: [DeveloperLexiconEntry] = [
        entry("--save-dev", ["dash dash save dev", "save dev flag"], profiles: [.terminal, .code]),
        entry("--save-exact", ["dash dash save exact", "save exact flag"], profiles: [.terminal, .code]),
        entry("--legacy-peer-deps", ["dash dash legacy peer deps"], profiles: [.terminal, .code]),
        entry("--frozen-lockfile", ["dash dash frozen lockfile"], profiles: [.terminal, .code]),
        entry("--ignore-scripts", ["dash dash ignore scripts"], profiles: [.terminal, .code]),
        entry("--no-install", ["dash dash no install"], profiles: [.terminal, .code]),
        entry("--dry-run", ["dash dash dry run"], profiles: [.terminal, .code]),
        entry("--force", ["dash dash force"], profiles: [.terminal, .code]),
        entry("--recursive", ["dash dash recursive"], profiles: [.terminal, .code]),
        entry("--watch", ["dash dash watch"], profiles: [.terminal, .code]),
        entry("--version", ["dash dash version"], profiles: [.terminal, .code]),
        entry("--help", ["dash dash help"], profiles: [.terminal, .code]),
        entry("--global", ["dash dash global"], profiles: [.terminal, .code]),
        entry("--yes", ["dash dash yes"], profiles: [.terminal, .code]),
        entry("--init", ["dash dash init"], profiles: [.terminal, .code]),
        entry("--prod", ["dash dash prod"], profiles: [.terminal, .code]),
        entry("--production", ["dash dash production"], profiles: [.terminal, .code]),
        entry("--template", ["dash dash template"], profiles: [.terminal, .code]),
        entry("--rm", ["dash dash rm"], profiles: [.terminal, .code]),
        entry("--path", ["dash dash path"], profiles: [.terminal, .code]),
    ]

    private static func entry(
        _ canonical: String,
        _ spokenVariants: [String],
        profiles: Set<TranscriptionProfile> = TranscriptionProfile.allProfiles,
        commandHeadEligible: Bool = false
    ) -> DeveloperLexiconEntry {
        DeveloperLexiconEntry(
            canonical: canonical,
            spokenVariants: Array(Set(spokenVariants.map { $0.lowercased() })),
            profiles: profiles,
            commandHeadEligible: commandHeadEligible
        )
    }

    private static let shellCommandsBlock = """
alias
arch
awk
base64
basename
bash
bat
bg
bind
brew
brotli
bun
bzip2
cat
cd
chflags
chmod
chown
clear
cmp
comm
cp
cron
crontab
curl
cut
date
dd
defaults
df
diff
dig
dirname
dmesg
du
echo
egrep
env
eval
exec
exit
export
false
fg
file
find
fmt
for
free
fswatch
fzf
getent
git
grep
gunzip
gzip
head
history
hostname
htop
ifconfig
jobs
jq
kill
killall
less
ln
locate
logname
ls
lsblk
lsof
make
man
md5
mkdir
mktemp
more
mount
mv
nano
nc
netcat
netstat
nice
nohup
nslookup
open
openssl
pbcopy
pbpaste
ping
pkill
pwd
python
python3
readlink
realpath
renice
rm
rmdir
rsync
ruby
scp
screen
sed
seq
set
sh
sha1sum
sha256sum
shellcheck
shift
shuf
sleep
sort
source
split
sqlite3
ssh
ssh-add
ssh-agent
sshd
stat
stty
sudo
sw_vers
tail
tar
tee
test
time
tmux
top
touch
tr
tree
true
truncate
tsort
tty
uname
unzip
uptime
users
uuidgen
vi
vim
watch
wc
which
who
whoami
xargs
xcodebuild
xcrun
xmllint
xz
yarn
yes
zip
zsh
"""

    private static let cliToolsBlock = """
act
adb
airflow
ansible
argocd
aws
az
bazel
celery
certbot
circleci
clang
clj
clojure
cmake
composer
conda
copilot
corepack
cosign
deno
docker
docker-compose
doctl
dotnet
drizzle-kit
eslint
fastlane
firebase
fly
forge
gh
ghcup
gcloud
ghq
go
gofmt
golangci-lint
helm
heroku
httpie
hugo
hyperfine
java
javac
just
k3d
k3s
kind
kubectl
kustomize
lein
lerna
llama
makepkg
meteor
minikube
mix
mongosh
nest
netlify
next
nix
npm
npx
nx
ollama
openapi-generator
parcel
pdm
php
phpunit
pip
pipenv
playwright
pnpm
poetry
pod
podman
pre-commit
prettier
prisma
pulumi
pytest
pyright
rails
redis-cli
render
ruff
rustc
rustfmt
sam
sass
serverless
shopify
skaffold
supabase
svgo
swift
swiftformat
swiftlint
terraform
terragrunt
thrift
turborepo
turbo
twine
typeorm
uv
uvicorn
vault
vercel
vite
vitest
webpack
wezterm
wrangler
yq
zola
"""

    private static let languagesBlock = """
ActionScript
Ada
AssemblyScript
Bash
C
Clojure
COBOL
CoffeeScript
Crystal
Dart
Elixir
Elm
Erlang
Fortran
GDScript
Gleam
Groovy
Haskell
HCL
Java
Julia
Kotlin
Lisp
Lua
MATLAB
Nim
Objective-C
OCaml
Perl
PHP
PowerShell
Prolog
Python
R
Racket
Ruby
Rust
Scala
Shell
Solidity
SQL
Sass
SCSS
Swift
TypeScript
Vala
Visual Basic
Zig
"""

    private static let frameworksBlock = """
Actix
Alpine.js
Angular Material
Apollo Client
Apollo Server
Astro
Backbone
BullMQ
Chakra UI
Chart.js
D3
DaisyUI
Day.js
Elysia
Emotion
Fastify
Formik
Framer Motion
Gatsby
Gin
Gin Gonic
HTMX
Hono
Hotwire
Inertia
Koa
Lodash
Mantine
Materialize
MobX
MUI
Nano Stores
NextAuth
Node Fetch
OpenAPI
Phoenix
Pinia
Pino
Plotly
Preact
Quasar
Radix UI
React Hook Form
React Query
React Router
Redux
Remix
RxJS
SWR
Semantic UI
Socket.IO
Solid Start
Spring Boot
Styled Components
Svelte
TanStack Router
TanStack Table
Three.js
TRPC
Tailwind CSS
Unocss
VitePress
Vue Router
Vuetify
Webpack
XState
Zod
Zustand
"""

    private static let frontendPackagesBlock = """
ajv
axios
clsx
date-fns
dotenv
esbuild
eslint-config-next
framer-motion
immer
isomorphic-fetch
jsdom
lucide-react
marked
markdown-it
msw
nanostores
nodemon
papaparse
postcss
prettier-plugin-tailwindcss
react-aria
react-dropzone
react-hot-toast
react-icons
react-markdown
react-spring
recharts
rollup
sharp
shiki
tailwind-merge
tailwind-variants
ts-node
tsx
typescript-eslint
unist
unified
uuid
valtio
vite-plugin-svgr
zustand-middleware
@apollo/client
@auth/core
@babel/core
@babel/preset-env
@babel/preset-react
@babel/preset-typescript
@clerk/nextjs
@headlessui/react
@heroicons/react
@hookform/resolvers
@langchain/openai
@mdx-js/react
@next/mdx
@playwright/test
@radix-ui/react-accordion
@radix-ui/react-alert-dialog
@radix-ui/react-avatar
@radix-ui/react-checkbox
@radix-ui/react-dialog
@radix-ui/react-dropdown-menu
@radix-ui/react-hover-card
@radix-ui/react-label
@radix-ui/react-navigation-menu
@radix-ui/react-popover
@radix-ui/react-progress
@radix-ui/react-radio-group
@radix-ui/react-scroll-area
@radix-ui/react-select
@radix-ui/react-separator
@radix-ui/react-slider
@radix-ui/react-slot
@radix-ui/react-switch
@radix-ui/react-tabs
@radix-ui/react-toast
@radix-ui/react-toggle
@radix-ui/react-tooltip
@reduxjs/toolkit
@sentry/nextjs
@sentry/react
@storybook/react
@supabase/supabase-js
@tailwindcss/forms
@tailwindcss/typography
@tanstack/react-query
@tanstack/react-router
@tanstack/react-table
@trpc/client
@trpc/react-query
@trpc/server
@types/node
@types/react
@types/react-dom
@vercel/analytics
@vitejs/plugin-react
"""

    private static let backendPackagesBlock = """
aiohttp
alembic
asyncpg
beautifulsoup4
black
boto3
celery
click
cryptography
daphne
fastapi
flask
gunicorn
httpx
hypothesis
jinja2
loguru
marshmallow
mypy
nltk
numpy
orjson
pandas
passlib
polars
psycopg
psycopg2
pyjwt
pymongo
pytest-asyncio
python-dotenv
redis-py
requests
scikit-learn
scipy
sqlalchemy
starlette
tenacity
uvicorn
werkzeug
aiosqlite
attrs
bandit
coverage
dataclasses-json
faker
grpcio
grpcio-tools
matplotlib
msgpack
networkx
opentelemetry-api
opentelemetry-sdk
packaging
pillow
prometheus-client
pydantic
pydantic-settings
pyyaml
rich
ruff
seaborn
sentence-transformers
spacy
tenacity
tqdm
transformers
typer
uvloop
whitenoise
django-rest-framework
flask-cors
flask-sqlalchemy
google-cloud-storage
langchain
llama-index
openai
pinecone-client
pytest-cov
pytest-mock
sqlmodel
"""

    private static let infraAndCloudBlock = """
ACM
Active Directory
Amazon ECS
Amazon EKS
Amazon S3
Amazon SES
Amazon SNS
Amazon SQS
Amazon VPC
API Gateway
Argo CD
Artifact Registry
Auto Scaling
Azure Blob Storage
Azure DevOps
BigQuery
Caddy
CircleCI
Cloud Build
Cloud Run
Cloud SQL
CloudWatch
CodeBuild
CodePipeline
Consul
DataDog
DigitalOcean Spaces
DNS
ECR
EC2
EKS
ELB
Fargate
GitHub Actions
GitLab CI
Grafana
Istio
KEDA
Kinesis
Lambda
Let's Encrypt
Load Balancer
MinIO
NATS
Nginx
Nomad
OpenFaaS
Prometheus
RDS
Route 53
S3
SES
SNS
SQS
Traefik
Vector
VPC
Vault
Webhook
WireGuard
Zero Trust
"""

    private static let dataAndProtocolsBlock = """
ACID
Apache Arrow
Avro
BSON
ClickHouse
CockroachDB
CORS
CRDT
CSV
Delta Lake
DuckDB
ETag
ETL
FTP
gRPC
GraphQL
HTTP
HTTPS
IDEMPOTENCY
IPC
JSON Schema
JWT
Kafka
Lakehouse
Loki
Memcached
MessagePack
MQTT
NATS JetStream
OLAP
OLTP
OpenAPI
Parquet
PostGIS
Pub/Sub
QUIC
RabbitMQ
Rate Limiting
RBAC
RLS
RPC
RSS
SAML
Schema Registry
SSE
SSH
SSL
TCP
TLS
UDP
URI
URL
UTC
UUID
Webhook
WebRTC
WebSocket
XML
YAML
"""
}
