var hppApp = angular.module('hppApp', ['ngAnimate','ngMessages','kendo.directives']);

String.prototype.FormatURL = function(){
    return this.replace('&amp;','&');
}