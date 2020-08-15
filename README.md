## Quick start

* The `examples` dir in this repo
* A barebones project:
  * https://github.com/paranim/parakeet
* Slightly bigger projects:
  * https://github.com/paranim/paranim_examples

## Intro

**_Why another game library?_**

These are the times that try men's souls. The harder the conflict, the more glorious the triumph; what we obtain too cheap, we esteem too lightly.

**_I'm not following..._**

We're drowning in abstractions and I want out, hombre! Game engines are a kitchen sink full of utencils to help you make the same game that a dozen people have already made, and the rest of us have already played. Delay your gratification, millenial. Let's make games with hand tools again.

**_You want to get rid of abstractions? I don't see any assembly here._**

No, I just want to choose them more carefully. It's the same way I approach alcohol. In my foolish youth I bought Natty Light and Jack Daniels, but now I savor a glass of Woodford Reserve and do various other things that make me better than you.

**_What can it do?_**

As little as possible while still being useful. The core abstraction is called an "entity", which is definitely not a horribly overloaded word. It is a bundle of state that lets you draw something. There's a really basic one built in called a `TwoDEntity` that can draw simple shapes:

```nim
# examples/src/ex02_rect.nim

var entity: TwoDEntity

proc init*(game: var Game) =
  doAssert glInit()

  # create a rectangle and put it somewhere
  var uncompiledEntity = initTwoDEntity(primitives.rectangle[GLfloat]())
  uncompiledEntity.project(float(game.frameWidth), float(game.frameHeight))
  uncompiledEntity.translate(50f, 50f)
  uncompiledEntity.scale(100f, 100f)
  uncompiledEntity.color(vec4(1f, 0f, 0f, 1f))

  # compile it so it can be rendered
  entity = compile(game, uncompiledEntity)

proc tick*(game: Game) =
  glClearColor(1f, 1f, 1f, 1f)
  glClear(GL_COLOR_BUFFER_BIT)
  glViewport(0, 0, GLsizei(game.frameWidth), GLsizei(game.frameHeight))
  render(game, entity)
```

Notice what we *don't* wrap. There is no need to wrap `glInit`, `glClear`, etc. They work fine, why hide them behind a stupid layer?

**_All that does is draw a red square. What about an image?_**

There is an `ImageEntity` for that. You need to use an external library called STB image to load the image:

```nim
# examples/src/ex01_image.nim

const image = staticRead("assets/aintgottaexplainshit.jpg")

var entity: ImageEntity

proc init*(game: var Game) =
  doAssert glInit()

  var
    width, height, channels: int
    data: seq[uint8]
  data = stbi.loadFromMemory(cast[seq[uint8]](image), width, height, channels, stbi.RGBA)
  var uncompiledImage = initImageEntity(data, width, height)
  uncompiledImage.project(float(game.frameWidth), float(game.frameHeight))
  uncompiledImage.translate(0f, 0f)
  uncompiledImage.scale(float(width), float(height))
  entity = compile(game, uncompiledImage)
```

**_How many can I render at once?_**

I don't know, try it. At some point you should start using instanced rendering, which lets you draw multiple things with one `render` call. Both of the above entities have "instanced" versions. For example, you can put a bunch of rectangles together like this:

```nim
# examples/src/ex03_rand_rects.nim

var entity: InstancedTwoDEntity

proc init*(game: var Game) =
  doAssert glInit()

  let baseEntity = initTwoDEntity(primitives.rectangle[GLfloat]())
  var uncompiledEntity = initInstancedEntity(baseEntity)

  for _ in 0 ..< 50:
    var e = baseEntity
    e.project(float(game.frameWidth), float(game.frameHeight))
    e.translate(cfloat(rand(game.frameWidth)), cfloat(rand(game.frameHeight)))
    e.scale(cfloat(rand(300)), cfloat(rand(300)))
    e.color(vec4(cfloat(rand(1.0)), cfloat(rand(1.0)), cfloat(rand(1.0)), 1f))
    uncompiledEntity.add(e)

  entity = compile(game, uncompiledEntity)
```

**_What if I want to render something that isn't a simple shape or an image? What about 3D? What about text?_**

You can make your own entities. All the 3D examples just make custom entities with the right shaders and attributes/uniforms. I'll document how to do this better in the future...maybe.

As for text, there is a separate library for that: [paratext](https://github.com/paranim/paratext). See the `ex27_text` example.

Paranim wraps a few other things that are normally hard to do manually. The `ex17_perspective_texture_meta_3d` example shows how to render to a texture, and the group of examples starting with `ex19_spheres_3d` show how to create an `IndexedEntity` (which calls OpenGL's `glDrawElements` function).

**_How do I play sounds?_**

To play wav or mp3 files, you can use [parasound](https://github.com/paranim/parasound). Additionally, you can even produce your own MIDI music with [paramidi](https://github.com/paranim/paramidi).

**_Is there any state management thingy? I want to use an entity component system. They're the future!_**

No. But I'm making a separate library called [pararules](https://github.com/paranim/pararules) which is a rules engine for Nim. This is uncharted territory for games but I think it might be a better (more holistic) solution than an ECS. If so, then expect it to go through the same maddening hype cycle that ECSs have gone through.

**_Wait, what the hell is a Nim?_**

A programming language. Like all good things, you probably haven't heard of it. I am mainly using it because it's the only "systems" language with a good AST macro system, which is essential to building a rules engine like pararules.

**_Rust has macros, no?_**

Rust has "procedural" macros but they are unhygenic and limited. I get the feeling that it is hard to add a good macro system to a language after it matures...just like it's hard to add a static type system to a dynamic language. A good macro system grows with its language, and ideally is used to implement a large part *of* the language.

I also don't want to pay Rust's hefty complexity tax just to get rid of that GC. My Rust code would easily be twice as long as my Nim code and far harder to read, write, and refactor. GC will not be the reason you never finish your game — complexity will. Buena suerte, amigo.

**_What about Vulkan? And WebGPU? And multi-threading?_**

As my grandma would say, "Don't give in to trend-chasing or mindless dogma that is totally detached from the realities of your problem domain." She said that shit to me when I was like five. True story.

I would like to add an abstraction for whatever replaces OpenGL when the dust settles, but for 99% of you I think OpenGL is still OK. If you are experiencing performance problems, it's probably your fault. And multi-threading is not a silver bullet. You are better off sticking to one thread for as long as you can.
