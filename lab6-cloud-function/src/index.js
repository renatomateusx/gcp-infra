exports.helloHttp = (req, res) => {
    const region = process.env.GCP_REGION || "UNKNOWN";
    const response = {
        message: `Hello World from Cloud Function at region ${region}`,
    }
    res.status(200).send(response);
};