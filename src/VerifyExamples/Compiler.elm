module VerifyExamples.Compiler exposing (compileTestSuite, todoSpec)

import String
import String.Util exposing (escape, indent, indentLines, unlines)
import VerifyExamples.Function as Function exposing (Function)
import VerifyExamples.ModuleName as ModuleName exposing (ModuleName)
import VerifyExamples.Test as Test exposing (Test)
import VerifyExamples.TestSuite as TestSuite exposing (TestSuite)


type alias Nomenclature =
    Int -> Test -> ModuleName


todoSpec : ModuleName -> ( ModuleName, String )
todoSpec moduleName =
    ( moduleName
    , unlines
        [ "module VerifyExamples." ++ ModuleName.toString moduleName ++ " exposing (..)"
        , ""
        , "-- This file got generated by [elm-verify-examples](https://github.com/stoeffel/elm-verify-examples)."
        , "-- Please don't modify this file by hand!"
        , ""
        , "import Test"
        , "import Expect"
        , ""
        , ""
        , "spec : Test.Test"
        , "spec ="
        , indent 1 <|
            "Test.todo \"module "
                ++ ModuleName.toString moduleName
                ++ ": No examples to verify yet!\""
        ]
    )


compileTestSuite : Nomenclature -> TestSuite -> List ( ModuleName, String )
compileTestSuite nomenclature suite =
    List.indexedMap
        (\index test ->
            let
                testModuleName =
                    nomenclature index test
            in
            ( testModuleName
            , compileTest testModuleName suite index test
            )
        )
        suite.tests


compileTest : ModuleName -> TestSuite -> Int -> Test -> String
compileTest testModuleName suite index test =
    unlines
        [ moduleHeader suite testModuleName
        , imports suite
        , unlines suite.types
        , ""
        , suite.helperFunctions
            |> List.map Function.toString
            |> unlines
        , ""
        , spec index test
        ]


moduleHeader : TestSuite -> ModuleName -> String
moduleHeader { imports } moduleName =
    unlines
        [ "module VerifyExamples." ++ ModuleName.toString moduleName ++ " exposing (..)"
        , ""
        , "-- This file got generated by [elm-verify-examples](https://github.com/stoeffel/elm-verify-examples)."
        , "-- Please don't modify this file by hand!"
        , ""
        ]


imports : TestSuite -> String
imports { imports } =
    unlines
        [ "import Test"
        , "import Expect"
        , ""
        , unlines imports
        , ""
        ]


spec : Int -> Test -> String
spec index test =
    unlines
        [ ""
        , ""
        , "spec" ++ toString index ++ " : Test.Test"
        , "spec" ++ toString index ++ " ="
        , indent 1 (testDefinition test)
        , indent 2 "\\() ->"
        , indent 3 "Expect.equal"
        , indentLines 4 (Test.specBody test)
        ]


testDefinition : Test -> String
testDefinition test =
    String.concat
        [ "Test.test \""
        , Test.name test
        , ": \\n\\n"
        , Test.exampleDescription test
            |> String.lines
            |> List.map (indent 1 >> escape)
            |> String.join "\\n"
        , "\" <|"
        ]
