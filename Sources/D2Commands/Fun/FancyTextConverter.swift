// Useful reference: https://unicode.scarfboy.com

struct FancyTextConverter {
    enum Alphabet: CaseIterable {
        case base
        case monospaced
        case boldScript
        case doubleStruck
        case fraktur
        case funky
        case fullwidth
        case taiViet
        case script
        case capital
        case squared
        case overlays
        case negativeSquared
        case `subscript`
        case circled
        case thai
        case greek
        case funky2

        var rawAlphabet: String {
            switch self {
            case .base: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            case .monospaced: "𝚊𝚋𝚌𝚍𝚎𝚏𝚐𝚑𝚒𝚓𝚔𝚕𝚖𝚗𝚘𝚙𝚚𝚛𝚜𝚝𝚞𝚟𝚠𝚡𝚢𝚣𝙰𝙱𝙲𝙳𝙴𝙵𝙶𝙷𝙸𝙹𝙺𝙻𝙼𝙽𝙾𝙿𝚀𝚁𝚂𝚃𝚄𝚅𝚆𝚇𝚈𝚉0𝟷𝟸𝟹𝟺𝟻𝟼𝟽𝟾𝟿"
            case .boldScript: "𝓪𝓫𝓬𝓭𝓮𝓯𝓰𝓱𝓲𝓳𝓴𝓵𝓶𝓷𝓸𝓹𝓺𝓻𝓼𝓽𝓾𝓿𝔀𝔁𝔂𝔃𝓐𝓑𝓒𝓓𝓔𝓕𝓖𝓗𝓘𝓙𝓚𝓛𝓜𝓝𝓞𝓟𝓠𝓡𝓢𝓣𝓤𝓥𝓦𝓧𝓨𝓩0123456789"
            case .doubleStruck: "𝕒𝕓𝕔𝕕𝕖𝕗𝕘𝕙𝕚𝕛𝕜𝕝𝕞𝕟𝕠𝕡𝕢𝕣𝕤𝕥𝕦𝕧𝕨𝕩𝕪𝕫𝔸𝔹ℂ𝔻𝔼𝔽𝔾ℍ𝕀𝕁𝕂𝕃𝕄ℕ𝕆ℙℚℝ𝕊𝕋𝕌𝕍𝕎𝕏𝕐ℤ𝟘𝟙𝟚𝟛𝟜𝟝𝟞𝟟𝟠𝟡"
            case .fraktur: "𝔞𝔟𝔠𝔡𝔢𝔣𝔤𝔥𝔦𝔧𝔨𝔩𝔪𝔫𝔬𝔭𝔮𝔯𝔰𝔱𝔲𝔳𝔴𝔵𝔶𝔷𝔄𝔅ℭ𝔇𝔈𝔉𝔊ℌℑ𝔍𝔎𝔏𝔐𝔑𝔒𝔓𝔔ℜ𝔖𝔗𝔘𝔙𝔚𝔛𝔜ℨ0123456789"
            case .funky: "卂𝓫ＣᗪẸƑgʰĮ𝐣ҜŁ𝓂ｎᵒ卩ⓆгＳᵗυ𝓥Ŵ𝕩ⓨŽᵃ𝓫𝒸Ď𝔢ᶠ𝔤卄𝔦ｊｋĹΜⓃ𝐎卩ＱŘⓈŤ𝕌𝔳Ⓦ𝓧𝕪𝓏Ѳ１➁❸４５６❼❽９"
            case .fullwidth: "ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ０１２３４５６７８９"
            case .taiViet: "ꪖ᥇ᥴᦔꫀᠻᧁꫝ꠸꠹ᛕꪶꪑꪀꪮρꪇ᥅ᦓꪻꪊꪜ᭙᥊ꪗƺꪖ᥇ᥴᦔꫀᠻᧁꫝ꠸꠹ᛕꪶꪑꪀꪮρꪇ᥅ᦓꪻꪊꪜ᭙᥊ꪗƺᦲ᧒ᒿᗱᔰƼᦆᒣᲖၦ"
            case .script: "𝒶𝒷𝒸𝒹𝑒𝒻𝑔𝒽𝒾𝒿𝓀𝓁𝓂𝓃🌸𝓅𝓆𝓇𝓈𝓉𝓊𝓋𝓌𝓍𝓎𝓏𝒜𝐵𝒞𝒟𝐸𝐹𝒢𝐻𝐼𝒥𝒦𝐿𝑀𝒩🌞𝒫𝒬𝑅𝒮𝒯𝒰𝒱𝒲𝒳𝒴𝒵💍𝟣𝟤𝟥𝟦𝟧𝟨𝟩𝟪𝟫"
            case .capital: "ᴀʙᴄᴅᴇꜰɢʜɪᴊᴋʟᴍɴᴏᴘQʀꜱᴛᴜᴠᴡxʏᴢᴀʙᴄᴅᴇꜰɢʜɪᴊᴋʟᴍɴᴏᴘQʀꜱᴛᴜᴠᴡxʏᴢ0123456789"
            case .squared: "🄰🄱🄲🄳🄴🄵🄶🄷🄸🄹🄺🄻🄼🄽🄾🄿🅀🅁🅂🅃🅄🅅🅆🅇🅈🅉🄰🄱🄲🄳🄴🄵🄶🄷🄸🄹🄺🄻🄼🄽🄾🄿🅀🅁🅂🅃🅄🅅🅆🅇🅈🅉0123456789"
            case .overlays: "a̸̻̰͊̆̽̚͘b̸̥̙̠͚͇̝̤̖̯͐́͐̋̀͂̀̾̐̏c̴͎̻̼̹͕͙͕̟̬̜̿̓͊̇̏d̶̨͚͕͙̼̦̄͑͘è̴̤̙̲̐̀́̈͝f̸̗͚͖͈̈́̓͊̌͗͛̾͑̇g̸̹̹̮̱̖͇͈̔̃͂̏̔̈̉h̵̥̤͉̜̑į̴̛̜͖̥̠̺͎̈̊͂̈́̒͊j̴̻̮̝̝̉̈́̈̂̿̊̀̚ḳ̷͍͗̈̽͆̕͜͠͝l̴͍͖͓͓̦̙̓͝m̶̮̟͚̮̥̩͇͊̓͂̾̑ņ̸̰͕̮̗͈̱̗̮̯͒̓̅́̄̽̊o̷̢͈̣͍̮̠͒̽̏̂p̷̧̺̠̯̲̫̝͎̥̀̃̋̉̆̽́q̸̤͖̭̲̟̟̮̏ṙ̸̡͇̯̖̰̯͓̤̄̃̆͒̌ş̵̯͇̾̐ͅṭ̷̽̄̍́͊̂̚ű̷̪̺̠̈́͌͐͛̊̀͗v̴͔͖̥̣͚̫̰͔͎̿̀w̵̢̼̞̲̫̱͈͔͍̜̑͊͑͑͐̈̕x̴̳̙̣͙͓̿̀̎̈́̈y̶̖͕̭͈̪̖̹̓̽̅̈̿͝͝͝z̶̯̽̀A̵̬͓̺̠̖͓̭̘̱̐̈́̿B̸̨̩͈͎̏̒̂̊̽̎ͅC̴̡̡̤͒͑D̸͚̩̗̲̓̎̀̓͠͝Ë̷̛͔͈͔̳́̅̄̄F̸̼̮͖͍̟̪̜̗͈͈͒͛̐͛͂̒͋̅̓̓G̶̛̋̏̀̓͑̕ͅH̶͇͍̫͉̬͑̕I̴̥̞͛̉̑͑͌͊́͛̈͜J̶͕̕Ķ̷̘͉̯͙̜̈́̅̅̉̂ͅL̴̢̹̤̹̮̟̂̔M̷̡̠̺̲̤͙̓N̸̜̰̮͉̉̊͒̾͝Ȯ̶̧̼̩̤̈́̍P̷̤͍͌͋Q̵̢͎̻̥̺̗̺̜̦̹̿̈̆̒̃͗R̸̜̪̝͖̰͙̝͑̽̊̌͝S̶̺̻̳͎̾͜T̵̙͉̤̭͓̬̩̳͖̜͐͝Ù̶̧̩̇͝V̶͉͕̞̝̾̋͐͋͋̀̋̕W̸̢̠͙̮͓͕̤̠̺͎͋̔͋̀̌X̶̧͈̞̮̺̰̰͆͊̑̈́͆͘Y̸͙͇̲͓̲̝̫̩̟̙͗̍̈́̈́̈̈́̓̄͝͝Z̴̢̻͕͓͈̞͙̼͚̳̽͘0̷̝͓̟̊̔͊̏̈́̏͂͠1̸̲̻̹̍̒2̴͙̝͈̓̋͂̕3̸̱̘͈͌͐̒͑4̷̧̱̟̰͇̭̼͌̄̈́̾͒̈́̿͘͠ͅͅ5̸͔̲̞̹̳͙͎̥́͂͋͛́͜6̶͈̬̯̫̖͚̿̊̎͆̓7̷͈̰̱͙͙̠̈̋̄̈́͘ͅ8̵̨̺̟͔̠̩̣̪̪̆̃̿̈̔̃̂̃͆͝9̶̮̜͉̰̝͙̲̑̀̕͠"
            case .negativeSquared: "🅰🅱🅲🅳🅴🅵🅶🅷🅸🅹🅺🅻🅼🅽🅾🅿🆀🆁🆂🆃🆄🆅🆆🆇🆈🆉🅰🅱🅲🅳🅴🅵🅶🅷🅸🅹🅺🅻🅼🅽🅾🅿🆀🆁🆂🆃🆄🆅🆆🆇🆈🆉0123456789"
            case .subscript: "ₐbcdₑfgₕᵢⱼₖₗₘₙₒₚqᵣₛₜᵤᵥwₓyzₐBCDₑFGₕᵢⱼₖₗₘₙₒₚQᵣₛₜᵤᵥWₓYZ₀₁₂₃₄₅₆₇₈₉"
            case .circled: "ⓐⓑⓒⓓⓔⓕⓖⓗⓘⓙⓚⓛⓜⓝⓞⓟⓠⓡⓢⓣⓤⓥⓦⓧⓨⓩⒶⒷⒸⒹⒺⒻⒼⒽⒾⒿⓀⓁⓂⓃⓄⓅⓆⓇⓈⓉⓊⓋⓌⓍⓎⓏ⓪①②③④⑤⑥⑦⑧⑨"
            case .thai: "ค๒ς๔єŦﻮђเןкɭ๓ภ๏קợгรՇยשฬאץչค๒ς๔єŦﻮђเןкɭ๓ภ๏קợгรՇยשฬאץչ0123456789"
            case .greek: "αႦƈԃҽϝɠԋιʝƙʅɱɳσρϙɾʂƚυʋɯxყȥABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            case .funky2: "ǟɮƈɖɛʄɢɦɨʝӄʟʍռօքզʀֆȶʊʋաӼʏʐǟɮƈɖɛʄɢɦɨʝӄʟʍռօքզʀֆȶʊʋաӼʏʐ0123456789"
            }
        }
    }

    func convert(_ s: String, from sourceAlphabet: Alphabet = .base, to targetAlphabet: Alphabet) -> String {
        let rawSourceAlphabet = sourceAlphabet.rawAlphabet
        let rawTargetAlphabet = targetAlphabet.rawAlphabet
        return String(s.map { rawSourceAlphabet.firstIndex(of: $0).flatMap { rawTargetAlphabet[safely: $0] } ?? $0 })
    }
}
