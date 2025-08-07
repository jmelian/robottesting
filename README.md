# robottesting

Este repositorio contiene un proyecto de ejemplo que utiliza un framework de testing para la automatización de pruebas, ideal para sistemas robóticos o cualquier otro sistema que requiera desarrollo dirigido por pruebas (TDD).

---

### Descripción del Proyecto

El proyecto demuestra el uso de un framework de testing genérico y multiplataforma. Permite desarrollar y ejecutar pruebas unitarias de manera independiente del lenguaje y del middleware, organizando los casos de prueba en suites y utilizando un *test runner* automatizado para su ejecución.

---

### Tecnologías Utilizadas

* **Python:** Lenguaje principal de desarrollo y para la creación de tests.
* **XML:** Utilizado para la configuración de las suites de pruebas.
* **Robot Framework:** Un framework de automatización de código abierto que facilita las pruebas de aceptación y la automatización de procesos.

---

### Instalación

Para empezar a utilizar este proyecto, sigue los siguientes pasos:

1.  **Clona el repositorio:**
    ```bash
    git clone [https://github.com/jmelian/robottesting.git](https://github.com/jmelian/robottesting.git)
    cd robottesting
    ```

2.  **Instala las dependencias (si aplica):**
    Si el proyecto utiliza Robot Framework, es probable que necesites instalarlo vía `pip`.
    ```bash
    pip install robotframework
    ```

---

### Uso

Para ejecutar las pruebas del proyecto, usa el comando adecuado del *test runner*. Por ejemplo, si usas `Robot Framework`, el comando podría ser:

```bash
robot tests/
```

Esto ejecutará todos los casos de prueba que se encuentren en el directorio `tests/` y generará los reportes correspondientes.

### Contribuciones
Las contribuciones son bienvenidas. Si deseas mejorar el proyecto, por favor:

Haz un "fork" del repositorio.

Crea una nueva rama (`git checkout -b feature/nueva-funcionalidad`).

Realiza tus cambios y haz un "commit" (`git commit -am 'Add new feature'`).

Haz un "push" a la rama (`git push origin feature/nueva-funcionalidad`).

Crea una nueva solicitud de extracción (`Pull Request`).

### Licencia
Este proyecto está bajo la licencia Apache 2.0.
