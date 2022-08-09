if [[ ! -s /etc/condor/passwords.d/POOL ]]; then
    ( flock -n 200 || exit 0;
    echo POOL is empty;
    condor_store_cred add -c -p `/etc/condor/passwords.d/passgen.py`;
    chmod 600 /etc/condor/passwords.d/POOL;
    condor_token_create -id condor@$SERVICE_FQDN -token condor.idtoken;
    condor_token_create -id frontend@$SERVICE_FQDN > /root/frontend-tokens.d/frontend.$SERVICE_FQDN.idtoken;
    chown frontend.frontend /root/frontend-tokens.d/*;
    ) 200>/etc/condor/passwords.d/POOL;
else
    echo POOL is not empty;
fi;

until [[ -s /root/frontend-tokens.d/frontend.$SERVICE_FQDN.idtoken ]]; do
    sleep 1;
done;