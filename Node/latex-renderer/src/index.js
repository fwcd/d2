const mathjax = require("mathjax-node-svg2png");
const fs = require("fs");

(async () => {
    try {
        const args = process.argv;
        if (args.length < 4) {
            console.log("Usage: node " + args[1] + " [tex math] [output file]");
            return;
        }

        mathjax.start();
        const res = await mathjax.typeset({
            math: args[2],
            png: true
        });
        const base64PngData = res.png.replace(/^data:image\/png;base64,/, "");

        fs.writeFile(args[3], base64PngData, "base64", e => {
            if (e) console.log("Error while writing to file: " + e);
        });
    } catch (e) {
        console.log("Error: " + e);
    }
})();
