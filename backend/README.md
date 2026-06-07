# PixelShare — Backend

API REST em Go (Gin) para o app de pixel art colaborativo.

## Stack

- **Go 1.22** + **Gin 1.12**
- **PostgreSQL 16** (pixels armazenados como JSONB sparse)
- **Login básico por email e senha**
- **Docker Compose** para ambiente local

## Estrutura do projeto

```
pixelshare/
├── cmd/server/         # Entrypoint — main.go
├── internal/
│   ├── domain/         # Entidades e interfaces (contratos)
│   ├── repository/     # Implementações do banco de dados
│   ├── usecase/        # Regras de negócio
│   ├── handler/        # Controllers HTTP (Gin)
│   ├── middleware/     # Auth JWT
│   └── infra/db/       # Conexão e migrations
└── pkg/
    ├── hash/           # Bcrypt
    ├── token/          # JWT
    └── response/       # Helpers de resposta HTTP
```

## Como rodar

```bash
# Subir banco e API
docker-compose up --build

# Ou rodar localmente
cp .env.example .env
go run ./cmd/server
```

## Endpoints

### Auth
| Método | Rota             | Descrição       |
|--------|------------------|-----------------|
| POST   | /users/register  | Criar conta     |
| POST   | /users/login     | Login básico    |

### Usuários (autenticado)
| Método | Rota             | Descrição            |
|--------|------------------|----------------------|
| GET    | /users/me        | Perfil próprio       |
| PATCH  | /users/me        | Atualizar perfil     |
| GET    | /users/:id       | Perfil de outro user |
| GET    | /users/:id/artworks | Artes do user     |

Os endpoints autenticados abaixo esperam o header `X-User-Id` para identificar o usuário atual:

- `GET /users/:id`
- `GET /artworks/feed`
- `GET /artworks/:id`
- `POST /artworks`
- `PATCH /artworks/:id`
- `DELETE /artworks/:id`
- `POST /artworks/:id/like`
- `DELETE /artworks/:id/like`
- `GET /notifications`
- `GET /notifications/unread`
- `PATCH /notifications/read`

### Artes (autenticado)
| Método | Rota                  | Descrição           |
|--------|-----------------------|---------------------|
| GET    | /artworks/feed        | Feed global         |
| POST   | /artworks             | Publicar arte       |
| GET    | /artworks/:id         | Ver arte            |
| PATCH  | /artworks/:id         | Editar arte         |
| DELETE | /artworks/:id         | Deletar arte        |
| POST   | /artworks/:id/like    | Curtir              |
| DELETE | /artworks/:id/like    | Descurtir           |

### Notificações (autenticado)
| Método | Rota                    | Descrição              |
|--------|-------------------------|------------------------|
| GET    | /notifications          | Listar notificações    |
| GET    | /notifications/unread   | Contagem não lidas     |
| PATCH  | /notifications/read     | Marcar todas como lida |

## Formato dos pixels

Pixels são armazenados de forma **sparse** — apenas pixels coloridos são enviados.
Pixels sem cor (fundo transparente) simplesmente não existem no mapa.

```json
{
  "title": "meu cogumelo",
  "width": 16,
  "height": 16,
  "pixels": {
    "0,0": "#FF0000",
    "0,1": "#FF0000",
    "1,0": "#FFFFFF",
    "3,7": "#000000"
  }
}
```

Tamanhos de canvas permitidos: `12, 16, 24, 32, 48, 64`

## Fluxo de notificações

Quando um usuário curte uma arte, o backend automaticamente cria
uma notificação para o dono da arte. O app Kotlin consome
`GET /notifications/unread` periodicamente para exibir o badge
e busca `GET /notifications` para listar.
