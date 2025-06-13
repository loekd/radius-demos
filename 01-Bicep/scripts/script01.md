clear
cd /Users/loekd/projects/radius-demos/01-Bicep

rad workspace list
rad workspace switch local

rad group create ateam
rad group show ateam -o json

rad env create --group ateam test 

rad run ./app_v1.bicep --group ateam --environment test --application demo01
$CTRL+C

rad app delete demo01 --group ateam -y