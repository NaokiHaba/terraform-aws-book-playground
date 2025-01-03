exports.lambda_handler = async (event, context) => {
    console.log("Hello World");
    
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: "Hello World"
        })
    };
};
