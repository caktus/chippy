# This is a starting tasks file for invoke-kubesae
# https://github.com/caktus/invoke-kubesae#usage
#
import invoke
from colorama import init
from kubesae import aws
from kubesae import deploy
from kubesae import image
from kubesae import pod


init(autoreset=True)


@invoke.task
def staging(c):
    c.config.env = "staging"
    c.config.namespace = "chippy-staging"


@invoke.task
def production(c):
    c.config.env = "production"
    c.config.namespace = "chippy-production"


ns = invoke.Collection()
ns.add_collection(image)
ns.add_collection(aws)
ns.add_collection(deploy)
ns.add_collection(pod)
ns.add_task(staging)
ns.add_task(production)

ns.configure(
    {
        "app": "chippy",
        "aws": {"region": "us-east-1",},
        # FIXME
        # "cluster": "caktus-chippy-cluster",
        "repository": "472354598015.dkr.ecr.us-east-1.amazonaws.com/chippy",
        "run": {"echo": True,},
    }
)
