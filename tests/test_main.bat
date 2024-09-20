@echo off

cls
call run_without_tests binom
call run_without_tests disktest
call run_without_tests sort
call run_without_tests triangle

cd coreftests2024b
call run_all

cd ..

