<img src="./assets/logo.png" align="left" width="200"/>

# `Cuby`

Cuby is a Discord bot built in Rust using the Twilight framework. It integrates with Ollama for AI-powered chat responses, with tool-calling support for tasks like setting reminders.

<br/>
<br/>

## Features

- **AI Chat**: Mention the bot in any channel to get a response powered by a self-hosted Ollama model. Supports conversation context and tool use.
- **Reminders**: Set reminders via `/remind`. Cuby stores them in SQLite and sends a ping when they expire, either in-channel or via DM.
- **PetPet**: Generate petpet GIFs from a user's avatar with `/pet`.
- **Server Shuffle**: Randomly pick members with `/server-shuffle`.

## Requirements

- Rust 2024 edition (install via [rustup](https://rustup.rs))
- A running [Ollama](https://ollama.com) instance with a model of your choice
- A Discord bot token ([Discord Developer Portal](https://discord.com/developers/applications))

## Setup

1. Clone the repo:

    ```sh
    git clone https://github.com/Cubic-Inc/Cuby.git
    cd Cuby
    ```

2. Create a `.env` file in the project root:

    ```sh
    DISCORD_TOKEN=your-discord-bot-token
    OLLAMA_URL=http://localhost:11434
    OLLAMA_MODEL=your-model-name
    OLLAMA_TOKEN=your-ollama-api-token
    ```

3. Build and run:

    ```sh
    cargo run --release
    ```

    The SQLite database (`cuby.db`) is created automatically on first run.

## License

Cuby is licensed under the [MIT License](LICENSE).
