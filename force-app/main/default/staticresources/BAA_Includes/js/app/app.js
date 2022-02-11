var baaApp = angular.module('baaApp', ['ngAnimate','ngMessages']);

String.prototype.FormatURL = function(){
    return this.replace('&amp;','&');
}