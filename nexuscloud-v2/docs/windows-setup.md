# Windows and WSL2 setup

1. In PowerShell run wsl --status and wsl -l -v. Confirm Ubuntu is version 2.
2. Open Ubuntu and run docker version and docker info. Both client and server sections must appear.
3. Clone the repository branch and enter nexuscloud-v2.
4. Copy .env.example to .env and set a unique Grafana password.
5. Run docker compose config, then docker compose up -d.
6. Validate with bash scripts/validate.sh.

Do not install another Docker distribution until checking whether an existing Docker Engine is already configured. Do not change Windows networking for this foundation phase.
