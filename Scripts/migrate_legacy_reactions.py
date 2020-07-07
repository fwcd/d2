import argparse
import discord
import json
import sqlite3

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--tokens_file", default="local/platformTokens.json", help="The JSON file containing the Discord token")
    parser.add_argument("--sqlite_file", default="local/messages.sqlite3", help="The sqlite database.")

    args = parser.parse_args()

    with open(args.tokens_file, "r") as f:
        token = json.loads(f.read())["discord"]
    
    db = sqlite3.connect(args.sqlite_file)
    client = discord.Client()

    @client.event
    async def on_ready():
        print("Ready!")

        message_ids = [v for [v] in db.execute("select message_id from legacy_reactions")]
        print(f"Found {len(message_ids)} legacy reactions, migrating...")

        for (i, message_id) in enumerate(message_ids):
            message = await client.fetch_message(message_id)
            for reaction in message.reactions:
                emoji = reaction.emoji

                async for user in reaction.users():
                    if isinstance(emoji, discord.Emoji) or isinstance(emoji, discord.PartialEmoji):
                        emoji_name = emoji.name
                    else:
                        emoji_name = emoji
                    db.execute("insert into reactions (message_id, emoji_name, user_id) values (?, ?, ?)", (message_id, emoji_name, user.id))
            
            if i % 50 == 0:
                print(f"Processed {i}/{len(message_id)} messages")


    print("Connecting to Discord...")
    client.run(token)

if __name__ == "__main__":
    main()
