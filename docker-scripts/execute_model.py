import yaml
import subprocess

if __name__ == "__main__":

    config = None

    with open("./docker-scripts/run_configuration.yaml") as f:
        print("Loading config")
        config = yaml.load(f, Loader=yaml.FullLoader)
        print(config)

    if config:
        cultivars = config["cultivars"]
        runtime_args = config["model_run_args"]

        for cultivar in cultivars:
            cultivar_components = cultivar.split(".")
            cultivar_file = cultivar_components[0] + "." + cultivar_components[1]

            c_file = config["cultivar_directory"] + cultivar_file

            with open(c_file) as cultivar_file:

                subprocess.call(
                    ["sed", "-i", f"/^{cultivar_components[2]}/ s/$/ */g", c_file]
                )

                # sed adds the * after the carriage return, so you must remove carriage returns for the model to work.
                subprocess.call(["sed", "-i", f"s/\r//", c_file])

                # cat_proc = subprocess.Popen(
                #     ["cat", c_file],
                #     stdout=subprocess.PIPE,
                #     stderr=subprocess.STDOUT,
                # )

                # print(f"Cat: {cat_proc.communicate()}")

        runtime_array = runtime_args.split(" ")

        model_run = subprocess.Popen(
            [
                "java",
                "-cp",
                "target/ToucanSNX-1.0-SNAPSHOT.jar:lib/*",
                "org.cgiar.toucan.App",
                *runtime_array,
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )

        print(f"Command is {model_run.args}")
        print(f"Comms: {model_run.communicate()}")
