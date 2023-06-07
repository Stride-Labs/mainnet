
sudo cp osmosis.service /etc/systemd/system/osmosis.service
sudo chmod 644 /etc/systemd/system/osmosis.service

sudo systemctl daemon-reload

sudo systemctl stop osmosis
sudo systemctl start osmosis
sudo systemctl status osmosis
sudo systemctl enable osmosis

journalctl -u osmosis.service -n 30