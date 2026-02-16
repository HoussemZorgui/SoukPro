const SibApiV3Sdk = require('@getbrevo/brevo');

const sendVerificationEmail = async (email, name, verificationCode) => {
    let apiInstance = new SibApiV3Sdk.TransactionalEmailsApi();
    apiInstance.setApiKey(SibApiV3Sdk.TransactionalEmailsApiApiKeys.apiKey, process.env.BREVO_API_KEY);

    let sendSmtpEmail = new SibApiV3Sdk.SendSmtpEmail();

    sendSmtpEmail.subject = "Code de vérification SoukPro";
    sendSmtpEmail.htmlContent = `
        <html>
            <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
                <div style="max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
                    <div style="text-align: center; margin-bottom: 25px;">
                        <img src="https://i.ibb.co/N6h5K1xh/Souk-Pro.png" alt="SoukPro Logo" style="height: 100px;">
                    </div>
                    <h1 style="color: #C9A24D; text-align: center; font-size: 24px;">Bienvenue sur SoukPro !</h1>
                    <p>Bonjour <strong>${name}</strong>,</p>
                    <p>Merci de vous être inscrit sur SoukPro. Pour activer votre compte, veuillez utiliser le code de vérification suivant :</p>
                    <div style="text-align: center; margin: 30px 0;">
                        <span style="font-size: 36px; font-weight: 800; letter-spacing: 5px; background: #fafafa; padding: 15px 25px; border-radius: 12px; border: 2px dashed #C9A24D; color: #0B1C2D; display: inline-block;">
                            ${verificationCode}
                        </span>
                    </div>
                    <p>Ce code est valable pendant 10 minutes. Ne le partagez avec personne.</p>
                    <p>Si vous n'avez pas créé de compte, vous pouvez ignorer cet e-mail.</p>
                    <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;">
                    <p style="font-size: 12px; color: #666; text-align: center;">© ${new Date().getFullYear()} SoukPro - Tous droits réservés.</p>
                </div>
            </body>
        </html>
    `;
    sendSmtpEmail.sender = { "name": "SoukPro", "email": process.env.EMAIL_FROM };
    sendSmtpEmail.to = [{ "email": email, "name": name }];

    try {
        const data = await apiInstance.sendTransacEmail(sendSmtpEmail);
        console.log('OTP Email envoyé avec succès. Code: ' + verificationCode);
        return true;
    } catch (error) {
        console.error('Erreur lors de l\'envoi de l\'email Brevo:', error.response ? error.response.body : error.message);
        return false;
    }
};

const sendWelcomeEmail = async (email, name) => {
    let apiInstance = new SibApiV3Sdk.TransactionalEmailsApi();
    apiInstance.setApiKey(SibApiV3Sdk.TransactionalEmailsApiApiKeys.apiKey, process.env.BREVO_API_KEY);

    let sendSmtpEmail = new SibApiV3Sdk.SendSmtpEmail();

    sendSmtpEmail.subject = "Bienvenue sur SoukPro ! 🚀 Your marketplace is ready";
    sendSmtpEmail.htmlContent = `
        <html>
            <body style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f9fafb; margin: 0; padding: 0;">
                <div style="max-width: 600px; margin: 20px auto; background-color: #ffffff; border-radius: 20px; overflow: hidden; box-shadow: 0 10px 25px rgba(0, 0, 0, 0.05);">
                    <div style="background: #0B1C2D; padding: 50px 20px; text-align: center; border-bottom: 5px solid #C9A24D;">
                        <img src="https://i.ibb.co/N6h5K1xh/Souk-Pro.png" alt="SoukPro Logo" style="height: 120px;">
                    </div>
                    <div style="padding: 40px 35px;">
                        <h2 style="color: #0B1C2D; margin-top: 0; font-size: 26px; font-weight: 800;">Félicitations, ${name} ! 🎉</h2>
                        <p style="color: #4b5563; font-size: 16px; line-height: 1.6;">
                            Votre compte est désormais vérifié et activé. Nous sommes ravis de vous compter parmi les membres de la communauté <strong>SoukPro</strong>.
                        </p>
                        <p style="color: #4b5563; font-size: 16px; line-height: 1.6;">
                            Une nouvelle expérience d'achat et de vente vous attend dès maintenant dans l'application.
                        </p>
                        
                        <div style="margin-top: 40px;">
                           <h3 style="color: #111827; font-size: 18px;">Ce que vous pouvez faire maintenant :</h3>
                           <ul style="color: #4b5563; padding-left: 20px; line-height: 1.8;">
                              <li>Parcourir les meilleures offres près de chez vous.</li>
                              <li>Mettre en vente vos objets en quelques secondes.</li>
                              <li>Suivre vos commandes en temps réel.</li>
                           </ul>
                        </div>

                        <div style="text-align: center; margin-top: 50px;">
                            <a href="#" style="background-color: #C9A24D; color: #ffffff; padding: 16px 45px; text-decoration: none; border-radius: 12px; font-weight: 800; font-size: 16px; display: inline-block; box-shadow: 0 4px 15px rgba(201, 162, 77, 0.3);">Lancer l'application</a>
                        </div>
                    </div>
                    <div style="background-color: #f3f4f6; padding: 20px; text-align: center;">
                        <p style="font-size: 12px; color: #9ca3af; margin: 0;">
                            © ${new Date().getFullYear()} SoukPro - La marketplace préférée des Tunisiens.<br>
                            Vous recevez cet e-mail car vous venez de vérifier votre compte.
                        </p>
                    </div>
                </div>
            </body>
        </html>
    `;
    sendSmtpEmail.sender = { "name": "SoukPro", "email": process.env.EMAIL_FROM };
    sendSmtpEmail.to = [{ "email": email, "name": name }];

    try {
        await apiInstance.sendTransacEmail(sendSmtpEmail);
        console.log('E-mail de bienvenue envoyé à: ' + email);
        return true;
    } catch (error) {
        console.error('Erreur lors de l\'envoi de l\'email de bienvenue:', error.response ? error.response.body : error.message);
        return false;
    }
};

module.exports = { sendVerificationEmail, sendWelcomeEmail };
