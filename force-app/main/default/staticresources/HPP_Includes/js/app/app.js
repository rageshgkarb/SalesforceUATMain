var hppApp = angular.module('hppApp', ['ngAnimate','ngMessages']);

String.prototype.FormatURL = function(){
    return this.replace('&amp;','&');
}