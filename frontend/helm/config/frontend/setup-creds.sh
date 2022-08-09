if [[ ! -s /etc/condor/passwords.d/FRONTEND ]]; then
    ( flock -n 200 || exit 0;
    echo FRONTEND is empty;
    condor_store_cred add -f /etc/condor/passwords.d/FRONTEND -p `/etc/condor/passwords.d/passgen.py`;
    chmod 600 /etc/condor/passwords.d/FRONTEND;
    cp /etc/condor/passwords.d/FRONTEND /root/condor-passwords.d;
    condor_token_create -id factory@$VO_POOL -key FRONTEND > /root/output-tokens/factory.$VO_POOL.idtoken;
    chown frontend.frontend /etc/condor/tokens.d/* /etc/condor/passwords.d/*;
    ) 200>/etc/condor/passwords.d/FRONTEND;
else
    echo FRONTEND is not empty;
fi;

until [[ -s /etc/condor/passwords.d/FRONTEND ]]; do
    sleep 1;
done;