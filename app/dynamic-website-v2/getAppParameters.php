<?php

require 'aws.phar'; #AWSSDK
#require 'aws-autoloader.php';
$ch = curl_init();

// get a valid TOKEN
$headers = array (
        'X-aws-ec2-metadata-token-ttl-seconds: 21600' );
$url = "http://169.254.169.254/latest/api/token";
#echo "URL ==> " .  $url;
curl_setopt( $ch, CURLOPT_HTTPHEADER, $headers );
curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true );
curl_setopt( $ch, CURLOPT_CUSTOMREQUEST, "PUT" );
curl_setopt( $ch, CURLOPT_URL, $url );
$token = curl_exec( $ch );

#echo "<p> TOKEN :" . $token;
// then get metadata of the current instance 
$headers = array (
        'X-aws-ec2-metadata-token: '.$token );

$url = "http://169.254.169.254/latest/meta-data/placement/availability-zone";

curl_setopt( $ch, CURLOPT_URL, $url );
curl_setopt( $ch, CURLOPT_HTTPHEADER, $headers );
curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true );
curl_setopt( $ch, CURLOPT_CUSTOMREQUEST, "GET" );
$result = curl_exec( $ch );
$az = curl_exec( $ch );

#echo "<p> RESULT :" . $result;

$region = substr($az, 0, -1);

$ssm_client = new Aws\Ssm\SsmClient([
  'version' => 'latest',
  'region'  => $region
]);

$showServerInfo = "";
$timeZone = "";
$currency = "";
$db_url = "";
$db_name = "";
$db_user = "";
$db_password = "";

function getParam($client, $name) {
  $r = $client->getParameter([
    'Name' => $name,
    'WithDecryption' => true
  ]);
  return $r['Parameter']['Value'];
}

try {
  $db_url         = getParam($ssm_client, '/cafe/dbUrl');
  $db_user        = getParam($ssm_client, '/cafe/dbUser');
  $db_password    = getParam($ssm_client, '/cafe/dbPassword');
  $db_name        = getParam($ssm_client, '/cafe/dbName');
  $currency       = getParam($ssm_client, '/cafe/currency');
  $timeZone       = getParam($ssm_client, '/cafe/timeZone');
  $showServerInfo = getParam($ssm_client, '/cafe/showServerInfo');
}
catch (Exception $e) {
  error_log('SSM error: ' . $e->getMessage());
  $db_url = '';
  $db_name = '';
  $db_user = '';
  $db_password = '';
  $showServerInfo = '';
  $timeZone = '';
  $currency = '';
}
?>