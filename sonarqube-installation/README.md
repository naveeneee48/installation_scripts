1. Steps to Trigger the Script via Webhook
**
Replace /path/to/repo with the path to your local clone of the repository.
Ensure the sonar-scanner command works properly on your server.
chmod +x /path/to/sonar-scan.sh

2. Configure Webhook in Gitea
Log in to your Gitea web interface.

Add a Webhook:

Go to your Gitea repository settings.
Navigate to Webhooks > Add Webhook.
Choose Gitea as the type.

Set the URL to the endpoint you will create for triggering the analysis script (e.g., http://<your-server>:5000/webhook).


Create a pre-push Git hook:

Navigate to your repo's .git/hooks directory.

move pre-hook.sh file to this repo
chmod +x .git/hooks/pre-push.sh


2. Test the Setup
Make a change in your repository and push it to Gitea.
Gitea will send a webhook request to your server.
The Flask listener will receive the webhook, triggering the sonar-scan.sh script.

3. Generate a Token: Use the new credentials to generate an access token for API or automation purposes:

curl -u username:password -X POST "http://<sonarqube-server-ip>:9000/api/user_tokens/generate" -d "name=<token_name>"

4. you can change the password using the REST API:

curl -u admin:admin -X POST "http://<sonarqube-server-ip>:9000/api/users/change_password" -d "login=admin" -d "password=NewStrongPassword"

5. Secure Best Practices
Disable Default Admin Login: After setting up another admin user, disable or delete the default admin user if not needed.
Use Tokens Instead of Passwords: Tokens are more secure than using username:password in scripts.

