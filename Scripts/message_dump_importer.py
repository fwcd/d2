# Imports messages from a dump into the sqlite db

import argparse
import re
import json
import sqlite3
import tarfile

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input_file", help="The message dump .tar.gz archive.")
    parser.add_argument("sqlite_file", help="The sqlite database file.")

    args = parser.parse_args()
    db = sqlite3.connect(args.sqlite_file)
    
    with tarfile.open(args.input_file, "r") as tar:
        for info in tar:
            file_name = info.name.split("/")[-1]
            if file_name.endswith(".json"):
                [channel_id, channel_name_raw, _] = re.split(r"_|\.", file_name)
                [channel_name, clean] = re.findall(r"^((?:.(?!clean))+)(?:-(clean))?", channel_name_raw.replace("-messages-log", ""))[0]
                if not clean:
                    print(f"Processing channel {channel_name}...")
                    with tar.extractfile(info) as f:
                        msgs = [json.loads(msg) for msg in f.readlines()]
                        for msg in msgs:
                            db.execute("insert into messages (message_id, author_id, channel_id, content, has_attachments, has_embed) values (?, ?, ?, ?, ?, ?)", (msg["id"], msg["author_id"], channel_id, msg["content"], 0, 0))
                        print(f"    Inserted {len(msgs)} messages")
    
    db.commit()

if __name__ == "__main__":
    main()
