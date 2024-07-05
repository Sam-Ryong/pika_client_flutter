bool checkCollision(player, block) {
  final hitbox = player.hitbox;
  final px = player.position.x + hitbox.offsetX;
  final py = player.position.y + hitbox.offsetY;
  final pw = hitbox.width;
  final ph = hitbox.height;

  final bx = block.x;
  final by = block.y;
  final bw = block.width;
  final bh = block.height;

  final fx = player.scale.x < 0 ? px - (hitbox.offsetX * 2) - pw : px;

  return (py < by + bh && py + ph > by && fx < bx + bw && fx + pw > bx);
}

bool checkCollisionWithObjects(ball, player) {
  final px = player.position.x;
  final py = player.position.y;
  final pw = player.width;
  final ph = player.height;

  final bx = ball.x;
  final by = ball.y;
  final bw = ball.width;
  final bh = ball.height;

  return (py < by + bh && py + ph > by && px < bx + bw && px + pw > bx);
}
