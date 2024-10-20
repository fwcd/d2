import D2TestUtils
import Testing
import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif
import Logging
@testable import D2NetAPIs

fileprivate let log = Logger(label: "WolframAlphaParserDelegateTests")

struct WolframAlphaParserDelegateTests {
    @Test func wolframAlphaParserDelegate() async throws {
        let xml = """
            <?xml version='1.0' encoding='UTF-8'?>
            <queryresult success='true'
                error='false'
                numpods='2'

            datatypes=''
                timedout=''
                timedoutpods=''
                timing='0.76'
                parsetiming='0.17500000000000002'
                parsetimedout='false'
                recalculate=''
                id='MSPa25771417ii4dic26d121000064be873f11g22g37'
                host='https://www5a.wolframalpha.com'
                server='43'
                related='https://www5a.wolframalpha.com/api/v2/relatedQueries.jsp?id=MSPa25781417ii4dic26d12100002ai371gc4hbdba616763155028757663219'
                version='2.6'>
            <pod title='Indefinite integral'
                scanner='Integral'
                id='IndefiniteIntegral'
                position='100'
                error='false'
                numsubpods='1'
                primary='true'>
            <subpod title=''>
                <img src='https://www5a.wolframalpha.com/Calculate/MSP/MSP25791417ii4dic26d12100001bia2e0e55i20eg5?MSPStoreType=image/gif&amp;s=43'
                    alt='integral4 dx = 4 x + constant'
                    title='integral4 dx = 4 x + constant'
                    width='155'
                    height='32'
                    type='Default'
                    themes='1,2,3,4,5,6,7,8,9,10,11,12' />
                <plaintext>integral4 dx = 4 x + constant</plaintext>
            </subpod>
            <states count='1'>
                <state name='Step-by-step solution'
                    input='IndefiniteIntegral__Step-by-step solution'
                    stepbystep='true' />
            </states>
            </pod>
            <pod title='Plot of the integral'
                scanner='Integral'
                id='Plot'
                position='200'
                error='false'
                numsubpods='1'>
            <subpod title=''>
                <img src='https://www5a.wolframalpha.com/Calculate/MSP/MSP25801417ii4dic26d12100000d506id140bcb5i7?MSPStoreType=image/gif&amp;s=43'
                    alt=''
                    title=''
                    width='313'
                    height='142'

            type='2DMathPlot_1'
                    themes='1,2,3,4,5,6,7,8,9,10,11,12' />
                <plaintext></plaintext>
                </subpod>
                </pod>
                <assumptions count='1'>
                <assumption type='Clash'
                    word='integral'
                    template='Assuming &quot;${word}&quot; is ${desc1}. Use as ${desc2} instead'
                    count='2'>
                <value name='IntegralsWord'
                    desc='an integral'

            input='*C.integral-_*IntegralsWord-' />
            <value name='NumberSetTypeWord'
                desc=' referring to a type of number'
                input='*C.integral-_*NumberSetTypeWord-' />
            </assumption>
            </assumptions>
            </queryresult>
            """

        let result = try await withCheckedThrowingContinuation { continuation in
            let parser = XMLParser(data: xml.data(using: .utf8)!)
            let delegate = WolframAlphaParserDelegate(continuation: continuation)

            parser.delegate = delegate

            log.debug("Starting to parse")
            let result = parser.parse()
            log.debug("Done")

            guard result else {
                Issue.record("XML parser should succeed")
                return
            }
        }

        #expect(result.success == true)
        #expect(result.error == false)
        #expect(result.numpods == 2)
        #expect((result.timing ?? 0.0).isApproximatelyEqual(to: 0.76))
        #expect(result.pods.count == 2)

        // TODO: More detailed testing
    }
}
