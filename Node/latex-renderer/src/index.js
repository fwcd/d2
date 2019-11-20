const mathjax = require("mathjax-node-svg2png");
const fs = require("fs");

(async () => {
    try {
        const args = process.argv;
        if (args.length < 6) {
            console.log("Usage: node " + args[1] + " [tex math] [color] [output file] [scale]");
            return;
        }
        const math = args[2];
        const color = args[3];
        const outputFile = args[4];
        const scale = args[5];

        mathjax.start();
        const res = await mathjax.typeset({
            math: "\\color{" + color + "}{" + math + "}",
            png: true,
            scale: scale
        });
        const base64PngData = res.png.replace(/^data:image\/png;base64,/, "");

        fs.writeFile(outputFile, base64PngData, "base64", e => {
            if (e) console.log("Error while writing to file: " + e);
        });
    } catch (e) {
        console.log("Error: " + e);
    }
})();
