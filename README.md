# Social Pixel

Aplicação mobile de criação e compartilhamento de pixel art, desenvolvida com Flutter no frontend e Go no backend, conectada a um banco de dados PostgreSQL hospedado no Supabase.

## O que foi proposto

Desenvolver uma aplicação móvel funcional que resolvesse um problema ou atendesse a uma necessidade específica de um público-alvo definido. A aplicação deveria conter múltiplas telas, integração com backend próprio, banco de dados, consumo de uma API externa, sistema de notificações, recurso de compartilhamento e uso de pelo menos um hardware do dispositivo móvel.

## O que foi implementado

### Proposta

O PixelShare resolve um problema simples: artistas de pixel art não têm um espaço dedicado para criar diretamente no celular e compartilhar suas obras com uma comunidade. O app permite criar pixel art em um canvas interativo, publicar no feed global e interagir com as artes de outros usuários.

---

### 1. Implementação mobile - Flutter

O app foi desenvolvido em Flutter, com tema escuro e identidade visual própria definida em `theme.dart`. A arquitetura do frontend separa responsabilidades em `screens/`, `widgets/`, `services/` e `models/`, seguindo o mesmo princípio de separação de camadas adotado no backend.

---

### 2. Múltiplas telas

O app possui seis telas com navegação funcional entre elas:

- Login - autenticação por email e senha
- Cadastro - criação de conta com username, email e senha
- Feed - listagem global de pixel arts publicadas com suporte a curtidas
- Canvas - editor de pixel art com canvas interativo
- Notificações - listagem de notificações recebidas com badge de não lidas
- Perfil - exibição de dados do usuário e grid com suas artes publicadas

A navegação entre as telas autenticadas é feita por uma `BottomNavigationBar` com três itens: feed, criar arte e perfil.

---

### 3. Backend funcional - Go + Gin

O backend foi desenvolvido em Go com o framework Gin, seguindo arquitetura em camadas:

- `domain/` - entidades, interfaces e erros de domínio
- `repository/` - acesso ao banco de dados
- `service/` - regras de negócio
- `handler/` - endpoints HTTP

Cada camada se comunica exclusivamente através de interfaces definidas no `domain`, garantindo desacoplamento. Os erros de domínio são nomeados no `service` e mapeados para status HTTP apenas no `handler`.

A autenticação é simplificada: o `user_id` trafega no header `X-User-Id` em todas as requisições autenticadas, sem uso de JWT ou tokens de sessão. Essa decisão foi intencional para manter o backend simples dentro do escopo da atividade.

Endpoints implementados:

| Método | Rota | Descrição |
|---|---|---|
| POST | `/users/register` | Criar conta |
| POST | `/users/login` | Login |
| GET | `/users/:id` | Perfil do usuário |
| PATCH | `/users/:id` | Atualizar perfil |
| GET | `/users/:id/artworks` | Artes de um usuário |
| GET | `/artworks/feed` | Feed global |
| POST | `/artworks` | Publicar arte |
| GET | `/artworks/:id` | Detalhes de uma arte |
| PATCH | `/artworks/:id` | Editar arte |
| DELETE | `/artworks/:id` | Deletar arte |
| POST | `/artworks/:id/like` | Curtir |
| DELETE | `/artworks/:id/like` | Descurtir |
| GET | `/notifications` | Listar notificações |
| GET | `/notifications/unread` | Contagem de não lidas |
| PATCH | `/notifications/read` | Marcar todas como lidas |

---

### 4. Banco de dados - Supabase

O banco é hospedado no Supabase e contém quatro tabelas:

- `users` - dados dos usuários
- `artworks` - artes publicadas, com os pixels armazenados como JSONB
- `likes` - relação muitos-para-muitos entre usuários e artes
- `notifications` - notificações geradas por curtidas

As migrations são executadas automaticamente na inicialização do servidor. A conexão utiliza pool de conexões configurado com `SetMaxOpenConns`, `SetConnMaxLifetime` e `SetConnMaxIdleTime` para evitar erros causados pelo Supabase encerrar conexões ociosas.

---

### 5. API externa - The Color API

A [The Color API](https://www.thecolorapi.com) é consumida na tela de canvas para exibir o nome da cor selecionada pelo usuário. Ao fechar o color picker, o hex da cor escolhida é enviado para `https://www.thecolorapi.com/id?hex=RRGGBB` e o nome retornado é exibido ao lado do seletor de cor. por exemplo, ao selecionar `#7C3AED`, a API retorna `"Blue Violet"`.

Essa integração agrega valor ao fluxo de criação, ajudando o usuário a identificar e nomear as cores que está usando em sua arte.

---

### 6. Sistema de notificações

Quando um usuário curte uma arte, o backend automaticamente cria uma notificação para o dono da arte na tabela `notifications`. O app implementa dois mecanismos de notificação:

Polling em background com Workmanager: a cada 15 minutos (limite mínimo imposto pelo Android), o `notification_poller.dart` consulta o endpoint `/notifications/unread`, compara com a contagem salva localmente via `SharedPreferences`, e dispara uma notificação local via `flutter_local_notifications` quando o número aumenta, exibindo o nome do usuário que curtiu.

Tela de notificações interna: uma tela dedicada lista todas as notificações recebidas, com badge no ícone da barra de navegação indicando a quantidade de não lidas. Ao abrir a tela, todas as notificações são marcadas como lidas automaticamente.

---

### 7. Compartilhamento

Na tela de canvas, o botão de compartilhar gera um PNG da arte atual diretamente na memória, sem dependência de widget renderizado na tela. O processo usa `ui.PictureRecorder` e `Canvas` para desenhar os pixels em uma imagem 512×512, que é salva em arquivo temporário e compartilhada via `Share.shareXFiles` do pacote `share_plus`, abrindo o share sheet nativo do Android.

---

### 8. Hardware do dispositivo - Acelerômetro

O canvas utiliza o acelerômetro do dispositivo via pacote `sensors_plus`. Ao detectar uma aceleração acima de 70 unidades (equivalente a um chacoalhão firme), o app exibe um dialog de confirmação para limpar o canvas inteiro. Um cooldown de 2 segundos evita disparos acidentais repetidos.

---

### Indo além

Além dos requisitos mínimos, foram implementados:

- Undo/Redo com histórico de 50 passos: botões de desfazer e refazer na toolbar do canvas, com os botões desabilitados automaticamente quando não há histórico disponível.
- Color picker HSV completo: integrado com a The Color API para nomear a cor selecionada em tempo real.
- Detecção de precisão no canvas: uso de `GlobalKey` e `RenderBox.globalToLocal()` para converter a posição global do toque para coordenadas locais do canvas com precisão, evitando o problema de offset entre o `GestureDetector` e o widget visível.
- Armazenamento sparse de pixels: apenas os pixels coloridos são armazenados como JSONB no banco (`"x,y": "#RRGGBB"`), economizando espaço e tornando o diff entre edições trivial.
- Drag para pintar: além do toque simples, `onPanStart` e `onPanUpdate` permitem pintar arrastando o dedo pelo canvas continuamente.

---

## Tecnologias utilizadas

| Camada | Tecnologia |
|---|---|
| Mobile | Flutter (Dart) |
| Backend | Go 1.22 + Gin 1.12 |
| Banco de dados | PostgreSQL 16 (Supabase) |
| Notificações locais | flutter_local_notifications |
| Background tasks | Workmanager |
| Acelerômetro | sensors_plus |
| Compartilhamento | share_plus |
| Color picker | flutter_colorpicker |
| API externa | The Color API |

---

## Como rodar

### Backend

```bash
git clone <url-do-repositorio>
cd backend
cp .env.example .env
# Preencha as variáveis do Supabase no .env
go run main.go
```

Ou com Docker:

```bash
docker-compose up --build
```

O servidor sobe em `http://localhost:8080`. As migrations são aplicadas automaticamente.

### Mobile

```bash
cd mobile
flutter pub get
# Ajuste a baseUrl em lib/services/api_service.dart para o IP do backend
flutter run
```

---

## Aprendizados

### Armazenamento de pixel art como mapa sparse

Uma das decisões mais relevantes do projeto foi entender que salvar uma imagem não significa salvar bytes de pixels em sequência. O canvas é armazenado como um mapa JSON onde a chave é `"x,y"` e o valor é a cor em hex, apenas os pixels que foram pintados existem no mapa. Um canvas 64×64 completamente vazio ocupa `{}` no banco; um parcialmente preenchido ocupa proporcional ao que foi pintado. Isso elimina a necessidade de processar imagens no servidor e torna o diff entre duas versões de uma arte trivial, bastando comparar os mapas.

### Geração de PNG em memória sem widget

Compartilhar a arte como imagem exigiu entender como o Flutter renderiza fora da árvore de widgets. A solução com `RepaintBoundary` falhou porque o widget precisava estar completamente renderizado na tela para captura, o que causava bugs visuais. A abordagem correta foi usar `ui.PictureRecorder` e `Canvas` diretamente, desenhando os pixels em memória com tamanho fixo de 512×512 e exportando como PNG sem nenhuma dependência de widget visível.

### Precisão do toque no canvas

O `localPosition` do `GestureDetector` apresentava um offset sistemático em relação ao canvas visual, os pixels pintados apareciam alguns pixels abaixo e à direita de onde o dedo tocava. O problema foi resolvido usando `GlobalKey` no container do canvas e `RenderBox.globalToLocal()` para converter a posição global do evento para coordenadas locais do widget exato, eliminando qualquer discrepância causada pela posição do widget na árvore.

---

## Dificuldades

### Notificações push em background

A dificuldade mais significativa foi o sistema de notificações. O `Workmanager` com `flutter_local_notifications` foi configurado corretamente para polling a cada 15 minutos, mas as notificações não apareciam como popup no dispositivo mesmo com todas as permissões concedidas.

A solução de contorno foi implementar uma tela de notificações interna ao app, com badge no ícone da navigation bar indicando a quantidade de não lidas. O polling continua rodando em background para manter o contador atualizado, mas a experiência principal de visualizar notificações foi deslocada para dentro do app, onde o controle é total e o comportamento é previsível.

### Erros intermitentes de servidor

Requisições ao backend eventualmente retornavam erro 500 na primeira tentativa e funcionavam na segunda. O diagnóstico levou tempo porque o erro não aparecia em desenvolvimento local, só em produção com o Supabase. A causa era o banco encerrando conexões ociosas e o Go tentando reutilizar uma conexão já fechada. Resolvido com configuração adequada do pool de conexões.

### Compatibilidade do Gradle com pacotes Flutter

Adicionar os pacotes de notificação e background exigiu ajustes nas configurações do projeto Android para que bibliotecas mais modernas funcionassem em versões mais antigas do sistema. Além disso, uma das dependências estava em uma versão desatualizada e incompatível com a versão atual do Flutter, o que gerava erros de compilação até ser atualizada.

---

## Pontos de melhoria

Cache local do feed: atualmente cada vez que o usuário acessa a tela de feed, todas as artes são buscadas novamente do banco via rede. Isso é lento, especialmente com muitas publicações. A melhoria seria implementar cache local com `SharedPreferences` ou `sqflite`, armazenando o feed carregado e invalidando apenas quando o usuário faz pull-to-refresh explicitamente.

Paginação incremental: o feed carrega um número fixo de itens de uma vez. Implementar scroll infinito com paginação incremental (`offset` crescente) reduziria o tempo de carregamento inicial e o volume de dados trafegados.

Autenticação mais robusta: a autenticação atual por `user_id` no header sem assinatura é funcional para o escopo da atividade, mas qualquer pessoa que conheça o UUID de um usuário pode agir em nome dele. JWT com expiração seria o próximo passo.

Compressão do PixelMap: para canvases grandes (64×64) com muitos pixels preenchidos, o JSONB pode crescer consideravelmente. Uma representação mais compacta como RLE (run-length encoding) reduziria o tamanho armazenado e o tempo de transferência.