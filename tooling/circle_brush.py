import math
import pygame

# Initialize Pygame
pygame.init()

# Set up the game window
size = 200
screen = pygame.display.set_mode((size, size), pygame.SCALED)
pygame.display.set_caption("Hello Pygame")

def draw_circle(brush_width):
    centre_x = int(size/2)
    centre_y = int(size/2)

    widths = []

    is_odd = 0
    if(brush_width != int(brush_width)): 
        is_odd = 1
        # brush_width += 0.5

    brush_width = math.ceil(brush_width)
    radius = brush_width-1
    x = 0
    y = -radius 
    max_x_val = 0

    while(x<=(-y)):
        x += 1
        max_x_val += 1
        y_mid = y+0.5

        if(y_mid*y_mid + x*x > radius*radius):
            y += 1
            widths.append(max_x_val)
            max_x_val = 0

    if(len(widths) >= 2 and widths[-1] >= widths[-2]):
        widths[-1] = 1
        widths.append(1)

    widths.sort(reverse=True)

    # print(widths)

    # rows = [[0,0] for i in range(brush_width)]
    row_starts = [0 for i in range(brush_width)]
    row_widths = [0 for i in range(brush_width)]
    index = 0
    column_index = brush_width-1
    new_width = 0
    column_x = brush_width

    for width in widths:
        new_width += width
        row_start = brush_width-new_width
        row_starts[index] = row_start
        row_widths[index] = (new_width)

        for i in range(width):
            row_starts[column_index] = brush_width-(column_x)
            row_widths[column_index] = column_x
            column_index -= 1
        column_x -= 1

        index += 1


    # y = 0
    # for row in rows:
    #     row_start, new_width = row
    #     new_width -= is_odd+1
    #     pygame.draw.line(screen, (0,0,0,255), (row_start,y), (row_start+new_width,y) )
    #     pygame.draw.line(screen, (0,0,0,255), (row_start,(brush_width*2)-y-is_odd-1), (row_start+new_width,(brush_width*2)-y-is_odd-1) )
    #     y += 1

    return([row_widths, row_starts])

    # x = 0
    # y = 0
    # for i in range(len(widths)):
    #     for j in range(widths[i]):
    #         screen.set_at((centre_x+x, centre_y+y-int(radius)), (255,0,0,255))
    #         screen.set_at((centre_y+y-int(radius), centre_x+x), pygame.Color(255,0,0,255))
    #         screen.set_at((centre_x+x, centre_y+radius-y), (255,0,0,255))
    #         screen.set_at((centre_y+radius-y, centre_x+x), pygame.Color(255,0,0,255))
            
    #         screen.set_at((centre_y+y-int(radius), centre_x-x), pygame.Color(255,0,0,255))
    #         screen.set_at((centre_x-x, centre_y+y-int(radius)), (255,0,0,255))
    #         screen.set_at((centre_x-x, centre_y+radius-y), (255,0,0,255))
    #         screen.set_at((centre_y+radius-y, centre_x-x), pygame.Color(255,0,0,255))

            # x += 1
            # y += 1

    # pygame.draw.line(screen, (0,0,0,255), (centre_x, centre_y-int(radius)),  (centre_x, centre_y-int(radius)+brush_width))
    # pygame.draw.line(screen, (0,0,0,255), (centre_x-int(radius), centre_y),  (centre_x-int(radius)+brush_width, centre_y))

# Game loop

row_widths = []
row_starts = []
brush_addr_ptrs = []

for i in range(1,17):
    brush_addr_ptrs.append(len(row_widths))
    new_row_widths, new_row_starts = draw_circle(i)
    row_widths.extend(new_row_widths)
    row_starts.extend(new_row_starts)


print(row_widths)
# print(row_starts)
print(brush_addr_ptrs)


# circle_size = 1
# running = True
# while running:
#     for event in pygame.event.get():
#         if event.type == pygame.QUIT:
#             running = False

#         if event.type == pygame.KEYDOWN:
#             if(event.key == pygame.K_UP):
#                 circle_size += 0.5
#             if(event.key == pygame.K_DOWN):
#                 circle_size -= 0.5
#     screen.fill((255, 255, 255))
#     draw_circle(circle_size)
#     pygame.display.update()

# Quit Pygame
pygame.quit()