const sharp = require("sharp");

(async () => {
    try {
        const args = process.argv;
        const help = `Usage: node ${args[1]} [tex math] [color] [height]`;
        let [math, color, scale] = args.slice(2);

        color ||= "white";
        scale ||= "1";
        scale = parseInt(scale);

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
        const svgBuffer = Buffer.from(svgString, "utf8");
        const pngBuffer = await sharp(svgBuffer, { density: scale * 100 }).png().toBuffer();
        process.stdout.write(pngBuffer);
    } catch (e) {
        console.log("Error: " + e);
    }
})();
