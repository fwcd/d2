const mathjax = require("mathjax-node-svg2png");

(async () => {
    const args = process.argv;
    if (args.length < 3) {
        console.log("Usage: node " + args[1] + " [tex math]");
        return;
    }

    mathjax.start();
    const res = await mathjax.typeset({
        math: args[2],
        svg: true
    });
    console.log(res.svg);
})();
