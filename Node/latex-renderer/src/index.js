const fs = require("fs");
const util = require("util");
const svg2img = util.promisify(require("svg2img"));

(async () => {
    const mathjax = await require("mathjax").init({
        loader: {
            load: ["input/tex", "output/svg"]
        }
    });

    try {
        const args = process.argv;
        if (args.length < 5) {
            console.log(`Usage: node ${args[1]} [tex math] [color] [scale]`);
            return;
        }
        const math = args[2];
        const color = args[3];
        const scale = args[4];

        const adaptor = mathjax.startup.adaptor;
        const svgNode = await mathjax.tex2svgPromise(`\\color{${color}}{${math}}`, {
            display: true,
            containerWidth: 80
        });

        const svgString = adaptor.innerHTML(svgNode);

        const pngBuffer = await svg2img(svgString);
        process.stdout.write(pngBuffer);
    } catch (e) {
        console.log("Error: " + e);
    }
})();
