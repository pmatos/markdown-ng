#lang setup/infotab
(define raco-commands '(("md"
                         (submod markdown-ng main)
                         "run markdown"
                         #f)))
(define scribblings '(("markdown-ng.scrbl" () (tool-library))))
(define clean '("compiled" "doc" "doc/markdown-ng"))
(define compile-omit-paths '("MarkdownTest_1.0.3" "test"))
