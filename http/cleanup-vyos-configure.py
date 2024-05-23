import json
from vyos.configtree import ConfigTree

config_path = '/config/config.boot'

with open(config_path, 'r') as file:
    config_string = file.read()

config = ConfigTree(config_string=config_string)

interfaces = config.list_nodes(['interfaces', 'ethernet'])

# remove all hw-id from interfaces ethernet since it cause issue on interface order
# for interface in interfaces:
#     hw_id_path = ['interfaces', 'ethernet', interface, 'hw-id']
#     if config.exists(hw_id_path):
#         config.delete(hw_id_path)

# remove all interfaces ethernet 
for interface in interfaces:
    hw_id_path = ['interfaces', 'ethernet', interface]
    config.delete(hw_id_path)

with open(config_path, 'w') as config_file:
    config_file.write(config.to_string())
