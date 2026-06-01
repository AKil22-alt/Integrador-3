# Agro Tech Goiás - Integrador

Aplicativo Flutter para monitoramento e controle inteligente de irrigação focado em gestão de água e energia para o segmento agrícola.

## Visão geral

O aplicativo apresenta:

- Tela de login com logo da Agro Tech Goiás
- Cadastro de usuário local usando `shared_preferences`
- Página Home com apresentação do projeto e navegação rápida
- Menu lateral com acesso às páginas de:
  - Monitoramento
  - Acionamento
  - Chatbot
- Layout em tons verdes para reforçar a identidade AgroTech

## Estrutura principal

- `lib/main.dart` - ponto de entrada do aplicativo
- `lib/login.dart` - tela de login
- `lib/cadastro.dart` - tela de cadastro de usuário
- `lib/home.dart` - tela principal / dashboard
- `lib/controlador.dart` - página de acionamento remoto
- `lib/chatbot.dart` - página do chatbot
- `lib/dashboard.dart` - possíveis telas de monitoramento e relatórios

## Dependências usadas

- `animated_splash_screen`
- `page_transition`
- `shared_preferences`
- `http`

## Configuração e execução

1. Instale as dependências do Flutter:

```bash
flutter pub get
```

2. Execute o aplicativo em um dispositivo ou emulador:

```bash
flutter run
```

## Assets

A imagem `images/AgroGoais.png` está registrada em `pubspec.yaml` e usada nas telas de login, home e dashboard.

## Notas

- A navegação é feita com `Navigator.push` entre as telas
- O cadastro grava email e senha localmente usando `SharedPreferences`
- O layout da Home agora destaca a proposta do sistema de irrigação inteligente com monitoramento em tempo real, controle remoto e chatbot
