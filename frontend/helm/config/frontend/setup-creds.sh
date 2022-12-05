if [[ ! -s /var/lib/gwms-frontend/passwords.d/FRONTEND ]]; then
    ( flock -n 200 || exit 0;
    echo "FRONTEND is empty";
    condor_store_cred add -f /var/lib/gwms-frontend/passwords.d/FRONTEND -p `/var/lib/gwms-frontend/passwords.d/passgen.py`;
    chmod 600 /var/lib/gwms-frontend/passwords.d/FRONTEND;
    cp /var/lib/gwms-frontend/passwords.d/FRONTEND /root/condor-passwords.d;
    chown -R frontend.frontend /var/lib/gwms-frontend/.condor/tokens.d/ /var/lib/gwms-frontend/passwords.d/;
    ) 200>/var/lib/gwms-frontend/passwords.d/FRONTEND;
else
    echo "FRONTEND is not empty";
fi;

until [[ -s /var/lib/gwms-frontend/passwords.d/FRONTEND ]]; do
    sleep 1;
done;