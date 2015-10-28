require('coffee-script/register');
var GetSubcriptions = require('./src/get-subscriptions');
module.exports = new GetSubcriptions().run;
