if htgettoken -i "$OIDC_TOKEN_ISSUER" -a "$VAULT_SERVER" -o /var/lib/gwms-frontend/.condor/tokens.d/"$VO_POOL".scitoken; 
then 
    chown -R frontend.frontend /var/lib/gwms-frontend/.condor; 
else
    echo "[`date`]:  Something went wrong renewing your scitoken; probably your vault token is missing or expired so it can't be automatically renewed. Please run the following command to fix it:
        kubectl exec -it $HOSTNAME -c vo-frontend -- /bin/sh -c \"htgettoken -i $OIDC_TOKEN_ISSUER -a $VAULT_SERVER -o /var/lib/gwms-frontend/.condor/tokens.d/$VO_POOL.scitoken && chown -R frontend.frontend /var/lib/gwms-frontend/.condor\"" \
        >> /var/log/gwms-frontend/scitoken-complaint/scitoken-complaint.log;
fi;