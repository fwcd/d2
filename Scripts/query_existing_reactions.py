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

        tracked_guild_ids = {v for [v] in db.execute("select guild_id from guilds where guild_tracked == 1")}
        print(f"Found {len(tracked_guild_ids)} tracked guilds, migrating...")

        for guild_id in tracked_guild_ids:
            guild = client.get_guild(guild_id)

            if guild:
                print(f"Processing tracked guild '{guild.name}''...")

                for channel in guild.channels:
                    print(f"  Processing channel '{channel.name}'...")

                    if isinstance(channel, discord.TextChannel):
                        i = 0
                        try:
                            async for message in channel.history(limit=None):
                                db.execute("insert or ignore into messages (message_id, author_id, channel_id, content, timestamp, has_attachments) values (?, ?, ?, ?, ?, ?)", (message.id, message.author.id, channel.id, message.content, message.created_at.isoformat(), bool(message.attachments)))

                                for reaction in message.reactions:
                                    emoji = reaction.emoji

                                    async for user in reaction.users():
                                        if isinstance(emoji, discord.Emoji) or isinstance(emoji, discord.PartialEmoji):
                                            emoji_name = emoji.name
                                        else:
                                            emoji_name = emoji
                                        db.execute("insert or ignore into reactions (message_id, emoji_name, user_id) values (?, ?, ?)", (message.id, emoji_name, user.id))

                                db.commit()
                                
                                if i % 50 == 0:
                                    print(f"    Processed {i} messages")
                                
                                i += 1
                        except Exception as e:
                            print(f"Warning: Could not read history of channel '{channel.name}': {e}")
            else:
                print(f"Warning: Invalid guild id {guild_id}")


    print("Connecting to Discord...")
    client.run(token)

if __name__ == "__main__":
    main()
