# West of Loathing: Frontera Espacial Cosmo-Soviética
## Proyecto didáctico HTML/CSS → WordPress

---

## ESTRUCTURA DEL PROYECTO

```
cosmo-sovietica/
│
├── index.html              → Portada / Inicio
│
├── pages/
│   ├── historia.html       → Página: Historia
│   ├── clases.html         → Archivo CPT: Clases
│   ├── planetas.html       → Archivo CPT: Planetas
│   ├── galeria.html        → Página: Galería
│   └── comprar.html        → Página: Comprar/Alistar
│
├── css/
│   └── style.css           → Hoja de estilos principal (con variables)
│
├── js/
│   └── main.js             → JavaScript (menú, animaciones, scroll)
│
└── README.md               → Este archivo
```

---

## MAPA DE MIGRACIÓN A WORDPRESS (Paso 2)

### Páginas normales → Pages de WordPress

| HTML                   | WordPress                    | URL             |
|------------------------|------------------------------|-----------------|
| index.html             | front-page.php               | /               |
| pages/historia.html    | page-historia.php            | /historia/      |
| pages/galeria.html     | page-galeria.php             | /galeria/       |
| pages/comprar.html     | page-comprar.php             | /comprar/       |

### Archivos de CPT → Custom Post Types

| HTML                   | WordPress                    | URL             |
|------------------------|------------------------------|-----------------|
| pages/clases.html      | archive-clase.php            | /clases/        |
| (tarjeta individual)   | single-clase.php             | /clases/{slug}/ |
| pages/planetas.html    | archive-planeta.php          | /planetas/      |
| (tarjeta individual)   | single-planeta.php           | /planetas/{slug}/|

---

## CÓMO REGISTRAR LOS CPTs EN WORDPRESS

Añadir en `functions.php` del tema:

```php
function registrar_cpts() {

    // CPT: Clases de personaje
    register_post_type('clase', [
        'labels' => [
            'name'          => 'Clases',
            'singular_name' => 'Clase',
            'add_new_item'  => 'Añadir nueva clase',
            'edit_item'     => 'Editar clase',
        ],
        'public'      => true,
        'has_archive' => true,
        'rewrite'     => ['slug' => 'clases'],
        'supports'    => ['title', 'editor', 'thumbnail'],
        'menu_icon'   => 'dashicons-groups',
    ]);

    // CPT: Planetas
    register_post_type('planeta', [
        'labels' => [
            'name'          => 'Planetas',
            'singular_name' => 'Planeta',
        ],
        'public'      => true,
        'has_archive' => true,
        'rewrite'     => ['slug' => 'planetas'],
        'supports'    => ['title', 'editor', 'thumbnail'],
        'menu_icon'   => 'dashicons-location',
    ]);
}
add_action('init', 'registrar_cpts');
```

---

## CAMPOS PERSONALIZADOS (ACF)

Para los stats de las clases (fuerza, intelecto, carisma), usar
**Advanced Custom Fields** (ACF) con campos de tipo:

- `fuerza`    → Number (0–100)
- `intelecto` → Number (0–100)
- `carisma`   → Number (0–100)
- `atributo`  → Text (Cuerpo / Mente / Carisma)
- `cita`      → Textarea (texto de propaganda)
- `autor_cita`→ Text

---

## VARIABLES CSS → `style.css` DEL TEMA WORDPRESS

El `css/style.css` se convierte en el `style.css` del tema.
Solo hay que añadir la cabecera de WordPress al principio:

```css
/*
Theme Name: Cosmo-Sovietica
Theme URI:  https://example.com
Author:     Tu nombre
Description: Tema West of Loathing Cosmo-Soviético
Version:    1.0
*/

/* ── el resto del CSS igual ── */
:root { ... }
```

---

## ARCHIVOS DE TEMA WORDPRESS QUE SE CREARÁN

```
wp-content/themes/cosmo-sovietica/
│
├── style.css           ← CSS del proyecto (con cabecera WP)
├── functions.php       ← Registrar CPTs, encolar scripts/estilos
├── index.php           ← Fallback obligatorio
├── header.php          ← El <header> de todos los HTML
├── footer.php          ← El <footer> de todos los HTML
├── front-page.php      ← Contenido de index.html
├── page.php            ← Plantilla genérica de página
├── page-historia.php   ← Plantilla específica de historia
├── page-galeria.php    ← Plantilla específica de galería
├── page-comprar.php    ← Plantilla específica de comprar
├── archive-clase.php   ← Lista de clases (loop WP)
├── single-clase.php    ← Clase individual
├── archive-planeta.php ← Lista de planetas (loop WP)
├── single-planeta.php  ← Planeta individual
└── js/
    └── main.js         ← Igual que el actual
```

---

## NOTAS PEDAGÓGICAS

### Variables CSS
Todas las variables están en `css/style.css` bajo `:root {}`.
Cambiar una variable aquí actualiza todo el sitio. Por ejemplo,
para cambiar el acento rojo soviético por azul:

```css
--color-rojo: #1a5296;  /* Antes era #c0281e */
```

### Estructura de páginas vs anclas
Este proyecto usa **páginas separadas** (historia.html, clases.html…)
en lugar de anclas en un solo HTML. Esto facilita directamente
la migración a WordPress, donde cada página es un objeto separado
con su propia URL, SEO y plantilla.

### CPTs vs Páginas
- **Página**: contenido único, sin repetición (Historia, Galería, Comprar)
- **CPT**: contenido que se repite con la misma estructura (Clases, Planetas)
  Los CPTs permiten que el cliente añada clases/planetas desde el admin
  sin tocar código.
