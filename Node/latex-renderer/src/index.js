const util = require("util");
const svg2img = util.promisify(require("svg2img"));

(async () => {
    try {
        const args = process.argv;
        const help = `Usage: node ${args[1]} [tex math] [color] [scale]`;
        let [math, color, scale] = args.slice(2);

        color ||= "white";
        scale ||= 1;

        if (!math) {
            console.log(help);
            return;
        }

        const mathjax = await require("mathjax-full").init({
            loader: {
                load: ["input/tex", "output/svg"]
            }
        });

        const adaptor = mathjax.startup.adaptor;
        const svgNode = await mathjax.tex2svgPromise(`\\color{${color}}{${math}}`, {
            display: true
        });

        const svgString = adaptor.innerHTML(svgNode);

        const pngBuffer = await svg2img(svgString);
        process.stdout.write(pngBuffer);
    } catch (e) {
        console.log("Error: " + e);
    }
})();
