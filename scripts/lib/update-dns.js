const AWSSDK = require('aws-sdk');

const UPDATE_INTERVAL_M = 10;
const {
  ACCESS_KEY_ID,
  SECRET_ACCESS_KEY,
  REGION = 'eu-west-2',
  HOSTED_ZONE_NAME,
  RECORD_NAME_PREFIX,
} = process.env;

AWSSDK.config.update({
  accessKeyId: ACCESS_KEY_ID,
  secretAccessKey: SECRET_ACCESS_KEY,
  region: REGION,
});

const route53 = new AWSSDK.Route53();

/**
 * Get the public IP of this server.
 *
 * @returns {string} IP if known.
 */
const getPublicIp = async () => {
  try {
    const { ip } = await fetch('https://api.ipify.org?format=json').then(r => r.json());
    return ip;
  } catch (e) {
    console.log('Failed to get public IP');
    console.log(e);
    return undefined;
  }
};

/**
 * Create the record if it doesn't exist.
 *
 * @param {string} hostedZoneId - Hosted zone ID.
 * @param {string} recordUrlName - Full record name.
 * @param {string} publicIp - Current public IP of the network.
 */
const createRecord = async (hostedZoneId, recordUrlName, publicIp) => {
  const res = await route53.changeResourceRecordSets({
    HostedZoneId: hostedZoneId,
    ChangeBatch: {
      Changes: [{
        Action: 'CREATE',
        ResourceRecordSet: {
          Name: `${recordUrlName}.`,
          Type: 'A',
          TTL: 60 * 5, // 5 minutes
          ResourceRecords: [{ Value: publicIp }],
        },
      }],
    },
  }).promise();
  console.log(res);
  console.log(`Created record ${recordUrlName}`);
};

/**
 * Fetch the Route53 record's current state.
 *
 * @param {string} publicIp - Current public IP of the network.
 * @returns {object} Hosted zone ID, current IP, record name.
 */
const fetchRecordData = async (publicIp) => {
  // Find the hosted zone
  const listZonesRes = await route53.listHostedZones().promise();
  const zone = listZonesRes.HostedZones.find(({ Name }) => Name.includes(HOSTED_ZONE_NAME));
  if (!zone) throw new Error(`Hosted zone with name including ${HOSTED_ZONE_NAME} not found`);

  // List the records
  const hostedZoneId = zone.Id;
  const recordUrlName = `${RECORD_NAME_PREFIX}.${HOSTED_ZONE_NAME}`;
  const listRecordsRes = await route53.listResourceRecordSets({
    HostedZoneId: hostedZoneId,
    MaxItems: '100',
  }).promise();
  const record = listRecordsRes.ResourceRecordSets.find(
    ({ Name }) => Name.includes(recordUrlName),
  );

  // Create it as up-to-date
  if (!record) {
    await createRecord(hostedZoneId, recordUrlName, publicIp);
    process.exit(0);
  }

  // Get the record value
  return {
    currentIp: record.ResourceRecords[0].Value,
    hostedZoneId,
    recordFullName: record.Name,
  };
};

/**
 * Update the Route53 record with the current public IP of the network.
 *
 * @param {string} publicIp - Current public IP of the network.
 * @param {string} hostedZoneId - Hosted zone ID.
 * @param {string} recordFullName - Full record name.
 */
const updateRoute53RecordIp = async (publicIp, hostedZoneId, recordFullName) => {
  const res = await route53.changeResourceRecordSets({
    HostedZoneId: hostedZoneId,
    ChangeBatch: {
      Changes: [{
        Action: 'UPSERT',
        ResourceRecordSet: {
          Name: recordFullName,
          Type: 'A',
          TTL: 60 * 5, // 5 minutes
          ResourceRecords: [{ Value: publicIp }],
        },
      }],
    },
  }).promise();
  console.log(res);
  console.log(`Updated record ${recordFullName}`);
};

/**
 * When a refresh should be performed.
 */
const onIpMonitorRefresh = async () => {
  // Get public IP
  const publicIp = await getPublicIp();
  if (!publicIp) {
    console.log(`Failed to get public IP, doing nothing`);
    return;
  }
  console.log(`Current public IP address: ${publicIp}`);

  // Read the Route53 record
  const { currentIp, hostedZoneId, recordFullName } = await fetchRecordData(publicIp);
  console.log(`Current record IP address: ${currentIp}`);

  // Update if required
  if (publicIp === currentIp) {
    console.log('IP addresses match, nothing to do');
    return;
  }

  console.log('Record is out of date, updating');
  await updateRoute53RecordIp(publicIp, hostedZoneId, recordFullName);
};

/**
 * Start monitoring the IP.
 */
const start = () => {
  setInterval(onIpMonitorRefresh, UPDATE_INTERVAL_M * 60 * 1000);
  onIpMonitorRefresh();
};

start();
