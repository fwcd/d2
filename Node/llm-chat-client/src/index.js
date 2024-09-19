import { Client } from "@gradio/client";
import * as readline from "node:readline";

// This is a small wrapper around a zephyr-7b-beta-based chat assistant, hosted
// publicly on Hugging Face Spaces:
//
// https://huggingface.co/spaces/d2-assistant/chat
//
// Launching the executable connects to the API, spawning a new session. Chat
// messages can be submitted via stdin as newline-delimited JSON objects:
//
//     interface Request {
//         message: string;
//         system_message?: string;
//         max_tokens?: number;
//         temperature?: number;
//         top_p?: number;
//     }
//
// The responses are emitted via stdout:
//
//     interface Response {
//         message: string;
//     }

const client = await Client.connect("d2-assistant/chat");

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
});

for await (const line of rl) {
    const request = JSON.parse(line);
    const result = await client.predict("/chat", request);
    const response = {
        message: result.data[0],
    };
    console.log(JSON.stringify(response));
}
