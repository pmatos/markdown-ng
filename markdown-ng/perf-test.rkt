#lang at-exp racket/base

(require (for-syntax racket/base)
         racket/file
         racket/format
         racket/string
         "ci-environment.rkt")

;; A poor change to the grammar can potentially have a large
;; performance impact. Check for that.

(module+ test
  (require rackunit
           "main.rkt")

  (require racket/runtime-path)
  (define-runtime-path test.md (build-path "test" "test.md"))

  (define (check-fast-enough)
    (displayln "Strict mode:")
    (parameterize ([current-strict-markdown? #t])
      (check-fast-enough*))
    (displayln "Non-strict mode (with extensions):")
    (parameterize ([current-strict-markdown? #f])
      (check-fast-enough*)))

  (define (check-fast-enough*)
    (define xs (run-times))
    (define avg (/ (exact->inexact (apply + xs)) (length xs)))
    (define best (apply min xs))
    (define worst (apply max xs))
    (displayln @~a{Timings: @(string-join (map ~a (sort xs <)) ", ") (sorted)
                   Average: @avg})
    (check-true (< avg 170))
    (check-true (< worst 200))
    ;; Check that best isn't _too_ good. If so, maybe test material
    ;; accidentally changed?
    (check-false (< best 10)))

  (define (run-times)
    (define test-reps 5)
    (define doc-reps 5)
    (define doc (let ([s (file->string test.md)])
                  (string-join (for/list ([i doc-reps])
                                 s)
                               "\n\n")))
    (displayln @~a{Using @test.md
                   appended @doc-reps times: @(string-length doc) chars and @(length (regexp-split "\n" doc)) lines. Doing @test-reps timings...})
    (for/list ([_ test-reps])
      (for ([_ 3]) (collect-garbage))
      (define-values (_ cpu real gc)
        (time-apply parse-markdown (list doc)))
      real))

  ;; We don't know how fast a CI environment will be, and furthermore
  ;; it could vary on each run. Therefore don't run this test there.
  (unless ci-environment?
    (check-fast-enough)))
