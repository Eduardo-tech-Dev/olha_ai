# 📋 Olha ai

Um aplicativo de gerenciamento de tarefas estilo Kanban desenvolvido em Flutter com Firebase, permitindo criar quadros colaborativos para organizar suas atividades.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-ffca28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

### 🔐 **Autenticação**
- Login e cadastro com email/senha
- Autenticação segura via Firebase Auth
- Persistência de sessão
- Tela de splash com verificação automática

### 📊 **Quadros Kanban**
- Criação de múltiplos quadros de tarefas
- Visualização em colunas: "A Fazer", "Em Progresso", "Feito"
- Interface drag-and-drop intuitiva
- Atualização em tempo real

### 📝 **Gerenciamento de Tarefas**
- Adicionar novas tarefas com títulos personalizados
- Seleção de ícones temáticos para cada tarefa
- Mover tarefas entre colunas arrastando
- Cores dinâmicas baseadas no status

### 👥 **Colaboração**
- Compartilhar quadros com outros usuários
- Trabalho colaborativo em tempo real
- Controle de acesso por email

### 🎨 **Interface**
- Design moderno com tema dark
- Animações suaves e responsivas
- Interface intuitiva e amigável
- Suporte a diferentes tamanhos de tela`

## 🛠️ Tecnologias Utilizadas

- **[Flutter](https://flutter.dev/)** - Framework de desenvolvimento mobile
- **[Firebase Auth](https://firebase.google.com/products/auth)** - Autenticação de usuários
- **[Cloud Firestore](https://firebase.google.com/products/firestore)** - Banco de dados em tempo real
- **[Firebase Core](https://firebase.google.com/)** - Configuração base do Firebase

## 📦 Dependências

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  uuid: ^4.2.1
```

## 🚀 Como Executar

### Pré-requisitos

- Flutter SDK (versão 3.0.0 ou superior)
- Dart SDK
- Android Studio / VS Code

### Instalação

1. **Clone o repositório:**
```bash
git clone https://github.com/Eduardo-tech-Dev/olha_ai.git
cd OLHA_AI
```

2. **Instale as dependências:**
```bash
flutter pub get
```

3. **Execute a aplicação:**
```bash
flutter run
```

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                    # Ponto de entrada
├── models/
│   └── task.dart               # Modelo de dados
├── screens/
│   ├── splash_screen.dart      # Tela de carregamento
│   ├── login_screen.dart       # Tela de login
│   ├── register_screen.dart    # Tela de cadastro
│   ├── home_screen.dart        # Lista de quadros
│   └── task_board_screen.dart  # Quadro principal
└── widgets/
    ├── task_column.dart        # Coluna de tarefas
    └── task_card.dart          # Card de tarefa
```

## 🎯 Como Usar

### 1. **Primeiro Acesso**
- Abra o app e faça seu cadastro
- Ou entre com uma conta existente

### 2. **Criando um Quadro**
- Na tela inicial, toque no botão "+"
- Digite o nome do seu quadro
- Toque em "Criar"

### 3. **Adicionando Tarefas**
- Dentro do quadro, toque no botão "+"
- Digite o título da tarefa
- Escolha um ícone representativo
- Toque em "Adicionar"

### 4. **Movendo Tarefas**
- Toque e arraste uma tarefa
- Solte na coluna desejada
- A atualização é automática

### 5. **Compartilhando Quadros**
- Toque no ícone de compartilhar
- Digite o email do colaborador
- Toque em "Compartilhar"

## 🔧 Funcionalidades Avançadas

### **Ícones Disponíveis**
- ✅ Lista de tarefas
- 📚 Estudos
- 🏠 Casa
- 💼 Trabalho
- 🐕 Pets
- 🛒 Compras
- E muitos outros...

### **Status das Tarefas**
- **A Fazer:** Tarefas pendentes (roxo)
- **Em Progresso:** Tarefas sendo executadas (laranja)
- **Feito:** Tarefas concluídas (verde)

## 👨‍💻 Autor

Desenvolvido com ❤️ por [Eduardo Cauê Passos de Oliveira](https://github.com/Eduardo-tech-Dev)

