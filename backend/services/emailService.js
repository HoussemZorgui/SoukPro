const SibApiV3Sdk = require('@getbrevo/brevo');

const sendVerificationEmail = async (email, name, verificationToken) => {
    let apiInstance = new SibApiV3Sdk.TransactionalEmailsApi();

    let apiKey = apiInstance.authentications['apiKey'];
    apiKey.apiKey = process.env.BREVO_API_KEY;

    let sendSmtpEmail = new SibApiV3Sdk.SendSmtpEmail();

    sendSmtpEmail.subject = "Vérifiez votre compte SoukPro";
    sendSmtpEmail.htmlContent = `
        <html>
            <body>
                <h1>Bienvenue sur SoukPro, ${name} !</h1>
                <p>Merci de vous être inscrit. Veuillez confirmer votre compte en cliquant sur le lien ci-dessous :</p>
                <a href="${process.env.FRONTEND_URL}/verify-email?token=${verificationToken}">Confirmer mon compte</a>
                <p>Si vous n'avez pas créé de compte, vous pouvez ignorer cet e-mail.</p>
            </body>
        </html>
    `;
    sendSmtpEmail.sender = { "name": "SoukPro", "email": process.env.EMAIL_FROM };
    sendSmtpEmail.to = [{ "email": email, "name": name }];

    try {
        const data = await apiInstance.sendTransacEmail(sendSmtpEmail);
        console.log('Email envoyé avec succès. ID: ' + JSON.stringify(data));
        return true;
    } catch (error) {
        console.error('Erreur lors de l\'envoi de l\'email Brevo:', error);
        return false;
    }
};

module.exports = { sendVerificationEmail };
